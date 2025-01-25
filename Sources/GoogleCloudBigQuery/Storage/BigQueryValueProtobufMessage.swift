import OrderedCollections
import SwiftProtobuf

struct BigQueryValueProtobufMessage: SwiftProtobuf.Message {

    let record: OrderedDictionary<String, BigQueryValue>
    let type: OrderedDictionary<String, BigQueryType>

    init() {
        self.record = [:]
        self.type = [:]
    }

    init(
        record: OrderedDictionary<String, BigQueryValue>,
        type: OrderedDictionary<String, BigQueryType>
    ) {
        self.record = record
        self.type = type
    }

    var unknownFields = SwiftProtobuf.UnknownStorage()
    static let protoMessageName = ""

    mutating func decodeMessage<D>(decoder: inout D) throws where D: SwiftProtobuf.Decoder {
        fatalError("\(#function) has not been implemented")
    }

    func traverse<V>(visitor: inout V) throws where V: SwiftProtobuf.Visitor {
        for (index, value) in record.values.enumerated() {
            let fieldNumber = index + 1
            switch (type.values[index], value.storage) {
            case (.string, .string(let value)):
                if let value {
                    try visitor.visitSingularStringField(
                        value: value,
                        fieldNumber: fieldNumber
                    )
                }
            case (.int64, .int64(let value)):
                if let value {
                    try visitor.visitSingularInt64Field(
                        value: value,
                        fieldNumber: fieldNumber
                    )
                }
            case (.float64, .float64(let value)):
                if let value {
                    try visitor.visitSingularDoubleField(
                        value: value,
                        fieldNumber: fieldNumber
                    )
                }
            case (.bool, .bool(let value)):
                if let value {
                    try visitor.visitSingularBoolField(
                        value: value,
                        fieldNumber: fieldNumber
                    )
                }
            case (.timestamp, .timestamp(let value)):
                if let value {
                    try visitor.visitSingularInt64Field(
                        value: Int64(value.timeIntervalSince1970 * 1_000_000),  // microseconds
                        fieldNumber: fieldNumber
                    )
                }
            case (.array(let elementType), .array(let values)):
                switch elementType {
                case .string:
                    try visitor.visitRepeatedStringField(
                        value: values.compactMap({
                            switch $0.storage {
                            case .string(let value):
                                return value
                            default:
                                throw EncodingError.invalidValue(
                                    $0,
                                    EncodingError.Context(
                                        codingPath: [], debugDescription: "Expected string value")
                                )
                            }
                        }), fieldNumber: fieldNumber)
                case .int64:
                    try visitor.visitRepeatedInt64Field(
                        value: values.compactMap({
                            switch $0.storage {
                            case .int64(let value):
                                return value
                            default:
                                throw EncodingError.invalidValue(
                                    $0,
                                    EncodingError.Context(
                                        codingPath: [], debugDescription: "Expected int64 value")
                                )
                            }
                        }), fieldNumber: fieldNumber)
                case .float64:
                    try visitor.visitRepeatedDoubleField(
                        value: values.compactMap({
                            switch $0.storage {
                            case .float64(let value):
                                return value
                            default:
                                throw EncodingError.invalidValue(
                                    $0,
                                    EncodingError.Context(
                                        codingPath: [], debugDescription: "Expected f loat64 value")
                                )
                            }
                        }), fieldNumber: fieldNumber)
                case .bool:
                    try visitor.visitRepeatedBoolField(
                        value: values.compactMap({
                            switch $0.storage {
                            case .bool(let value):
                                return value
                            default:
                                throw EncodingError.invalidValue(
                                    $0,
                                    EncodingError.Context(
                                        codingPath: [], debugDescription: "Expected bool value")
                                )
                            }
                        }), fieldNumber: fieldNumber)
                case .timestamp:
                    try visitor.visitRepeatedInt64Field(
                        value: values.compactMap({
                            switch $0.storage {
                            case .timestamp(let value):
                                return value.map { Int64($0.timeIntervalSince1970 * 1_000_000) }  // microseconds
                            default:
                                throw EncodingError.invalidValue(
                                    $0,
                                    EncodingError.Context(
                                        codingPath: [], debugDescription: "Expected timestamp value"
                                    )
                                )
                            }
                        }), fieldNumber: fieldNumber)
                case .struct(let valueType):
                    try visitor.visitRepeatedMessageField(
                        value: values.compactMap({
                            switch $0.storage {
                            case .struct(let value):
                                return value.map {
                                    BigQueryValueProtobufMessage(record: $0, type: valueType)
                                }
                            default:
                                throw EncodingError.invalidValue(
                                    $0,
                                    EncodingError.Context(
                                        codingPath: [], debugDescription: "Expected struct value")
                                )
                            }
                        }),
                        fieldNumber: fieldNumber
                    )
                case .array(_):
                    throw EncodingError.invalidValue(
                        value,
                        EncodingError.Context(
                            codingPath: [], debugDescription: "Can't write multi-dimensional arrays"
                        )
                    )
                }
            case (.struct(let valueType), .struct(let value)):
                if let value {
                    try visitor.visitSingularMessageField(
                        value: BigQueryValueProtobufMessage(record: value, type: valueType),
                        fieldNumber: fieldNumber
                    )
                }
            default:
                throw EncodingError.invalidValue(
                    value,
                    EncodingError.Context(
                        codingPath: [],
                        debugDescription: "Type does not match value: \(type) != \(value.storage)"
                    )
                )
            }
        }
    }

    func isEqualTo(message: any SwiftProtobuf.Message) -> Bool {
        guard let other = message as? Self else {
            return false
        }
        return self == other
    }

    static func == (
        lhs: BigQueryValueProtobufMessage, rhs: BigQueryValueProtobufMessage
    ) -> Bool {
        if lhs.record != rhs.record { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

func protoDescriptor(record: OrderedDictionary<String, BigQueryType>)
    -> Google_Protobuf_DescriptorProto
{
    .with { root in
        root.name = "BqMessage"
        root.field = record.enumerated().map { index, data in
            var fieldDescriptor = data.value.protoDescriptor(
                nestedTypes: &root.nestedType
            )
            fieldDescriptor.name = data.key
            fieldDescriptor.number = Int32(index + 1)
            // field.label = .optional
            return fieldDescriptor
        }
    }
}

extension BigQueryType {

    func protoDescriptor(
        nestedTypes: inout [Google_Protobuf_DescriptorProto]
    ) -> Google_Protobuf_FieldDescriptorProto {
        .with {
            switch self {
            case .string:
                $0.type = .string
            case .int64:
                $0.type = .int64
            case .float64:
                $0.type = .float
            case .bool:
                $0.type = .bool
            case .timestamp:
                $0.type = .int64
            case .array(let elementType):
                $0.label = .repeated
                let elementDescriptor = elementType.protoDescriptor(nestedTypes: &nestedTypes)
                $0.type = elementDescriptor.type
                $0.typeName = elementDescriptor.typeName
            case .struct(let `struct`):
                $0.type = .message
                $0.typeName = "N\(nestedTypes.count)"
                nestedTypes.append(GoogleCloudBigQuery.protoDescriptor(record: `struct`))
            }
        }
    }
}
