import Foundation
import GRPCCore
import Logging
import SwiftProtobuf

public actor BatchWriteStream {

    let streamName: String
    let grpcClient: Google_Cloud_Bigquery_Storage_V1_BigQueryWrite.ClientProtocol
    let logger: Logger

    init(
        streamName: String,
        grpcClient: Google_Cloud_Bigquery_Storage_V1_BigQueryWrite.ClientProtocol,
        logger: Logger
    ) {
        self.streamName = streamName
        self.grpcClient = grpcClient
        self.logger = logger
    }

    private enum WriteError: Error {
        case didNotIndicateSuccess
        case missingSchema
    }

    private var serializedRowsBuffer: [Data] = []
    private var offset: Int64 = 0
    private var writeTask: Task<Void, Error>?
    private var schema: Google_Protobuf_DescriptorProto?

    public nonisolated func write<Row: Encodable>(row: Row) async throws {
        try await write(rows: [row])
    }

    public nonisolated func write<Row: Encodable>(rows: [Row]) async throws {
        guard !rows.isEmpty else {
            return
        }

        await writeToBuffer(rows: try rows.map(encode))
        try await flushBuffer()  // TODO: Run async so we can add more rows to buffer during write?
    }

    private nonisolated func encode<Row: Encodable>(row: Row) throws -> (
        Data, Google_Protobuf_DescriptorProto
    ) {
        let encoder = Encoder(for: Row.self)
        try row.encode(to: encoder)

        let value = try encoder.bigQueryValue()
        switch (value.storage, value.type) {
        case (.struct(let value), .struct(let type)):
            if let value {
                return (
                    try BigQueryValueProtobufMessage(record: value, type: type).serializedData(),
                    GoogleCloudBigQuery.protoDescriptor(record: type)
                )
            }
            throw EncodingError.invalidValue(
                row,
                EncodingError.Context(
                    codingPath: [], debugDescription: "Encoded row must not be nil")
            )
        default:
            throw EncodingError.invalidValue(
                row,
                EncodingError.Context(
                    codingPath: [], debugDescription: "Encoded row must be a struct")
            )
        }
    }

    private func writeToBuffer(rows: [(Data, Google_Protobuf_DescriptorProto)]) {
        schema = rows.first?.1
        serializedRowsBuffer.append(contentsOf: rows.map(\.0))
    }

    private func flushBuffer() async throws {
        try await writeTask?.value

        let rows = serializedRowsBuffer
        let offset = offset
        serializedRowsBuffer.removeAll(keepingCapacity: true)
        self.offset += 1

        if !rows.isEmpty {
            guard let schema else {
                throw WriteError.missingSchema
            }

            writeTask = Task {
                try await write(serializedRows: rows, offset: offset, schema: schema)
            }
            try await writeTask?.value
        }
        writeTask = nil
    }

    func writeAndClose() async throws {
        try await flushBuffer()
    }

    private nonisolated func write(
        serializedRows: [Data],
        offset: Int64,
        schema: Google_Protobuf_DescriptorProto
    ) async throws {
        try await grpcClient.appendRows(
            metadata: [
                "x-goog-request-params": "write_stream=\(streamName)"
            ],
            requestProducer: { [streamName] writer in
                try await writer.write(
                    .with {
                        $0.writeStream = streamName
                        $0.offset = .with {
                            $0.value = offset
                        }
                        $0.rows = .protoRows(
                            .with {
                                $0.writerSchema = .with {
                                    $0.protoDescriptor = schema
                                }
                                $0.rows = .with {
                                    $0.serializedRows = serializedRows
                                }
                            })
                    }
                )
            },
            onResponse: { response in
                for try await message in response.messages {
                    switch message.response {
                    case .appendResult:
                        break  // Success
                    case .error(let rpcStatus):
                        let code =
                            RPCError.Code(.init(rawValue: Int(rpcStatus.code)) ?? .unknown)
                            ?? .unknown
                        switch code {
                        case .alreadyExists:
                            break
                        default:
                            throw RPCError(code: code, message: rpcStatus.message)
                        }
                    case .none:
                        throw WriteError.didNotIndicateSuccess
                    }
                }
            }
        )
    }
}
