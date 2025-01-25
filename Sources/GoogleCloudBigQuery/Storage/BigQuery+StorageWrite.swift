import Foundation
import GRPCCore
import Logging
import OrderedCollections
import RetryableTask
import SwiftProtobuf
import Tracing

extension BigQuery {

  public func batchWrite(
    datasetID: String,
    tableID: String,
    operation: (BatchWriteStream) async throws -> Void,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
  ) async throws {
    try await withSpan("bigquery-storage-write", ofKind: .client) { span in
      logger.debug("Creating stream for insert...")
      let stream = try await createStream(
        datasetID: datasetID,
        tableID: tableID,
        file: file,
        function: function,
        line: line
      )
      span.addEvent("stream-created")

      logger.debug("Stream created. Writing rows...")
      try await operation(stream)
      try await stream.writeAndClose()
      span.addEvent("writes-completed")

      logger.debug("Rows written. Finalizing stream...")
      try await finalize(stream: stream, file: file, function: function, line: line)
      span.addEvent("finalized")

      logger.debug("Stream finalized. Committing...")
      try await commit(stream: stream, file: file, function: function, line: line)
      span.addEvent("committed")
    }
  }

  private func createStream(
    datasetID: String,
    tableID: String,
    file: String,
    function: String,
    line: UInt
  ) async throws -> BatchWriteStream {
    let grpcClient = try self.grpcClient
    let response = try await withRetryableTask(
      logger: logger,
      operation: {
        try await grpcClient.createWriteStream(
          .with {
            $0.parent = "projects/" + projectID + "/datasets/" + datasetID + "/tables/" + tableID
            $0.writeStream = .with {
              $0.type = .pending
            }
          })
      },
      file: file,
      function: function,
      line: line
    )
    return BatchWriteStream(
      streamName: response.name,
      grpcClient: grpcClient,
      logger: logger
    )
  }

  private func finalize(stream: BatchWriteStream, file: String, function: String, line: UInt)
    async throws
  {
    let grpcClient = try self.grpcClient
    _ = try await withRetryableTask(
      logger: logger,
      operation: {
        try await grpcClient.finalizeWriteStream(
          .with {
            $0.name = stream.streamName
          })
      },
      file: file,
      function: function,
      line: line
    )
  }

  private func commit(stream: BatchWriteStream, file: String, function: String, line: UInt)
    async throws
  {
    let grpcClient = try self.grpcClient
    _ = try await withRetryableTask(
      logger: logger,
      operation: {
        try await grpcClient.batchCommitWriteStreams(
          .with {
            $0.parent =
              "projects/" + projectID + "/datasets/"
              + stream.streamName.components(separatedBy: "/")[3] + "/tables/"
              + stream.streamName.components(separatedBy: "/")[5]
            $0.writeStreams = [stream.streamName]
          })
      },
      file: file,
      function: function,
      line: line
    )
  }
}
