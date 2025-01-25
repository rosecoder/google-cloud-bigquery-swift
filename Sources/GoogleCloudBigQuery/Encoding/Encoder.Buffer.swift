import OrderedCollections

extension Encoder {

    final class Buffer {

        var value: Value

        enum Value {
            case actual(BigQueryValue)

            case array([Buffer], type: BigQueryType?)
            case `struct`(
                OrderedDictionary<String, Buffer>?, type: OrderedDictionary<String, BigQueryType>)
            case buffer(Buffer)
        }

        init() {
            self.value = .actual(.init(nil as Bool?))  // TODO: Throw somewhere if this is never overwritten?
        }

        init(value: Value) {
            self.value = value
        }

        var type: BigQueryType? {
            switch value {
            case .actual(let value):
                return value.type
            case .array(let values, let elementType):
                if let elementType {
                    return .array(elementType)
                }
                if let any = values.first {
                    return any.type
                }
                return nil  // Unable to resolve type yet, because the array is empty. This will throw an error later in the encoding process if not resolved.
            case .struct(_, let elementType):
                return .struct(elementType)
            case .buffer(let childBuffer):
                return childBuffer.type
            }
        }

        func bigQueryValue() throws -> BigQueryValue {
            switch value {
            case .actual(let value):
                return value

            case .buffer(let childBuffer):
                return try childBuffer.bigQueryValue()

            case .array(let array, let elementType):
                let resolvedElementType: BigQueryType
                if let elementType {
                    resolvedElementType = elementType
                } else {
                    guard let anyElement = array.first else {
                        throw EncodingError.invalidValue(
                            self,
                            EncodingError.Context(
                                codingPath: [],  // TODO: Set somehow?
                                debugDescription: "Unable to infer element type of array"
                            ))
                    }
                    guard let anyElementType = anyElement.type else {
                        throw EncodingError.invalidValue(
                            self,
                            EncodingError.Context(
                                codingPath: [],  // TODO: Set somehow?
                                debugDescription: "Unable to infer element type of array"
                            ))
                    }
                    resolvedElementType = anyElementType
                }
                return .init(
                    value: .array(try array.map { try $0.bigQueryValue() }),
                    type: .array(resolvedElementType)
                )

            case .struct(let `struct`, let elementType):
                return .init(
                    value: .struct(try `struct`?.mapValues { try $0.bigQueryValue() }),
                    type: .struct(elementType)
                )
            }
        }
    }
}
