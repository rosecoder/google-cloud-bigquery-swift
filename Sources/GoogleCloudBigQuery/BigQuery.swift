import AsyncHTTPClient
import Foundation
import GoogleCloudAuth
import GoogleCloudServiceContext
import Logging
import NIO
import NIOHTTP1
import ServiceLifecycle
import SwiftProtobuf

public final class BigQuery: BigQueryProtocol, Service {

  let logger = Logger(label: "bigquery")

  private let authorization: Authorization
  private let client: HTTPClient
  private let endpoint = "https://bigquery.googleapis.com"

  public enum ConfigurationError: Error {
    case missingProjectID
  }

  public let projectID: String

  public convenience init() async throws {
    guard let projectID = await (ServiceContext.current ?? .topLevel).projectID else {
      throw ConfigurationError.missingProjectID
    }
    try self.init(projectID: projectID)
  }

  public init(projectID: String) throws {
    self.projectID = projectID

    self.authorization = Authorization(
      scopes: ["https://www.googleapis.com/auth/bigquery"],
      eventLoopGroup: .singletonMultiThreadedEventLoopGroup
    )
    self.client = HTTPClient(
      eventLoopGroupProvider: .shared(.singletonMultiThreadedEventLoopGroup)
    )
  }

  public func run() async throws {
    await cancelWhenGracefulShutdown {
      while !Task.isCancelled {
        try? await Task.sleep(nanoseconds: .max / 2)
      }
    }
    try await client.shutdown()
    try await authorization.shutdown()
  }

  func request<Body: Message>(
    method: HTTPMethod,
    path: String,
    body: some Message
  ) async throws -> Body {
    let accessToken = try await authorization.accessToken()

    var request = HTTPClientRequest(url: endpoint + "/bigquery/v2/projects/\(projectID)" + path)  // TODO: Encode project id
    request.method = method
    request.headers.add(name: "Authorization", value: "Bearer " + accessToken)
    request.headers.add(name: "Content-Type", value: "application/json")
    request.body = .bytes(try body.jsonUTF8Data())

    let response = try await client.execute(request, timeout: .seconds(30))
    return try await handle(response: response)
  }

  private func handle<Body: Message>(response: HTTPClientResponse) async throws -> Body {
    switch response.status {
    case .ok, .created:
      let body = try await response.body.collect(upTo: 1024 * 1024)  // 1 MB
      var decodingOptions = JSONDecodingOptions()
      decodingOptions.ignoreUnknownFields = true
      decodingOptions.messageDepthLimit = 1_000
      return try Body.init(jsonUTF8Data: Data(buffer: body), options: decodingOptions)
    default:
      let body = try await response.body.collect(upTo: 1024 * 100)  // 100 KB

      let remoteError: RemoteError
      do {
        remoteError = try JSONDecoder().decode(RemoteError.self, from: body)
      } catch {
        throw UnparsableRemoteError()
      }
      throw remoteError
    }
  }

  struct RemoteError: Error, Decodable {

    let status: String
    let message: String

    enum TopLevelCodingKeys: String, CodingKey {
      case error
    }

    enum ErrorCodingKeys: String, CodingKey {
      case status
      case message
    }

    init(from decoder: any Swift.Decoder) throws {
      let topLevelContainer = try decoder.container(keyedBy: TopLevelCodingKeys.self)
      let errorContainer = try topLevelContainer.nestedContainer(
        keyedBy: ErrorCodingKeys.self, forKey: .error)
      self.status = try errorContainer.decode(String.self, forKey: .status)
      self.message = try errorContainer.decode(String.self, forKey: .message)
    }
  }

  struct UnparsableRemoteError: Error {}
}
