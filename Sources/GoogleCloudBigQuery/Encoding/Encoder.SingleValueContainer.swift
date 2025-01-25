#if canImport(Foundation)
    import Foundation
#endif

extension Encoder {

    struct SingleValueContainer: SingleValueEncodingContainer {

        let codingPath: [any CodingKey]
        let buffer: Encoder.Buffer
        let bigQueryType: BigQueryType?

        mutating func encodeNil() throws {
            if let bigQueryType {
                buffer.value = .actual(bigQueryType.nullValue)
                return
            }
            throw EncodingError.invalidValue(
                buffer,
                EncodingError.Context(
                    codingPath: codingPath,
                    debugDescription:
                        "Cannot encode nil value due to the type is unknown. Please add conformance to `QueryEncodable` to the type."
                )
            )
        }

        mutating func encode(_ value: Bool) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: String) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: Double) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: Float) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: Int) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: Int8) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: Int16) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: Int32) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: Int64) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: UInt) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: UInt8) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: UInt16) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: UInt32) throws {
            buffer.value = .actual(.init(value))
        }

        mutating func encode(_ value: UInt64) throws {
            if value > UInt64(Int64.max) {
                throw EncodingError.invalidValue(
                    value,
                    EncodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "UInt64 is not yet supported"
                    )
                )
            }
            buffer.value = .actual(.init(Int64(value)))
        }

        mutating func encode<T>(_ value: T) throws where T: Encodable {
            #if canImport(Foundation)
                if let date = value as? Date {
                    buffer.value = .actual(.init(date))
                    return
                }
            #endif

            let encoder = Encoder(
                codingPath: codingPath,
                bigQueryType: bigQueryType
                    ?? (T.self as? QueryEncodable.Type)?.bigQueryType
                    ?? BigQueryType(anySwiftType: T.self)
            )
            try value.encode(to: encoder)
            buffer.value = encoder.buffer.value
        }
    }
}
