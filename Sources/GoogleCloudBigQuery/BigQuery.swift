import AsyncHTTPClient
import Foundation
import GRPCCore
import GRPCNIOTransportHTTP2Posix
import GoogleCloudAuth
import GoogleCloudServiceContext
import Logging
import NIO
import NIOHTTP1
import ServiceLifecycle
import SwiftProtobuf
import Synchronization

public final class BigQuery: BigQueryProtocol, Service {

  let logger = Logger(label: "bigquery")

  private let authorization: Authorization
  private let _httpClient = Mutex<HTTPClient?>(nil)
  private let _grpcClient = Mutex<
    (GRPCClient, Task<Void, Error>, Google_Cloud_Bigquery_Storage_V1_BigQueryWrite.ClientProtocol)?
  >(nil)

  public enum ConfigurationError: Error {
    case missingProjectID
  }

  public let projectID: String

  public convenience init() async throws {
    guard let projectID = await (ServiceContext.current ?? .topLevel).projectID else {
      throw ConfigurationError.missingProjectID
    }
    self.init(projectID: projectID)
  }

  public init(projectID: String) {
    self.projectID = projectID

    self.authorization = Authorization(
      scopes: ["https://www.googleapis.com/auth/bigquery"],
      eventLoopGroup: .singletonMultiThreadedEventLoopGroup
    )
  }

  var httpClient: HTTPClient {
    _httpClient.withLock {
      if let client = $0 {
        return client
      }
      let client = HTTPClient(
        eventLoopGroupProvider: .shared(.singletonMultiThreadedEventLoopGroup)
      )
      $0 = client
      return client
    }
  }

  var grpcClient: Google_Cloud_Bigquery_Storage_V1_BigQueryWrite.ClientProtocol {
    get throws {
      try _grpcClient.withLock {
        if let (_, _, client) = $0 {
          return client
        }
        let grpcClient = GRPCClient(
          transport: try .http2NIOPosix(
            target: .dns(host: "bigquerystorage.googleapis.com"),
            transportSecurity: .tls
          ),
          interceptors: [
            AuthorizationClientInterceptor(authorization: authorization)
          ]
        )
        let client = Google_Cloud_Bigquery_Storage_V1_BigQueryWrite.Client(wrapping: grpcClient)
        let runTask = Task {
          try await grpcClient.run()  // TODO: Add error handling and forward somewhere to run function?
        }
        $0 = (grpcClient, runTask, client)
        return client
      }
    }
  }

  public func run() async throws {
    await cancelWhenGracefulShutdown {
      while !Task.isCancelled {
        try? await Task.sleep(nanoseconds: .max / 2)
      }
    }

    try await withThrowingDiscardingTaskGroup { group in
      group.addTask {
        let httpClient = self._httpClient.withLock { $0 }
        try await httpClient?.shutdown()

      }
      group.addTask {
        if let (grpcClient, runTask, _) = self._grpcClient.withLock({ $0 }) {
          grpcClient.beginGracefulShutdown()
          try await runTask.value
        }
      }
    }

    try await authorization.shutdown()
  }

  func request<Body: Message>(
    method: HTTPMethod,
    path: String,
    body: some Message
  ) async throws -> Body {
    let accessToken = try await authorization.accessToken()

    var request = HTTPClientRequest(
      url: "https://bigquery.googleapis.com/bigquery/v2/projects/\(projectID)" + path)  // TODO: Encode project id
    request.method = method
    request.headers.add(name: "Authorization", value: "Bearer " + accessToken)
    request.headers.add(name: "Content-Type", value: "application/json")
    request.body = .bytes(try body.jsonUTF8Data())

    let response = try await httpClient.execute(request, timeout: .seconds(30))
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
