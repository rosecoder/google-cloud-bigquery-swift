#if canImport(Foundation)
    import Foundation
#endif

extension Encoder {

    struct UnkeyedContainer: UnkeyedEncodingContainer {

        var codingPath: [CodingKey]
        let buffer: Encoder.Buffer
        let bigQueryType: BigQueryType?
        let elementType: BigQueryType?
        let userInfo: [CodingUserInfoKey: Any]

        var currentIndex: Int = -1

        var count: Int {
            currentIndex + 1
        }

        init(
            codingPath: [CodingKey],
            buffer: Buffer,
            bigQueryType: BigQueryType?,
            userInfo: [CodingUserInfoKey: Any]
        ) throws {
            self.codingPath = codingPath
            self.buffer = buffer
            self.userInfo = userInfo
            self.bigQueryType = bigQueryType

            if let bigQueryType {
                switch bigQueryType {
                case .array(let elementType):
                    self.buffer.value = .array([], type: elementType)
                    self.elementType = elementType
                default:
                    throw EncodingError.invalidValue(
                        buffer.value,
                        EncodingError.Context(
                            codingPath: codingPath,
                            debugDescription:
                                "Unkeyed container cannot be used for type \(bigQueryType)"
                        )
                    )
                }
            } else {
                self.buffer.value = .array([], type: nil)
                self.elementType = nil
            }
        }

        private mutating func write(value: Buffer) throws {
            switch buffer.value {
            case .array(var values, let elementType):
                if let elementType {
                    values.append(value)
                    buffer.value = .array(values, type: elementType)
                } else {
                    let typeOfValue = value.type
                    if let typeOfValue, let any = values.first, let typeOfAny = any.type {
                        if typeOfAny != typeOfValue {
                            throw EncodingError.invalidValue(
                                value,
                                EncodingError.Context(
                                    codingPath: codingPath,
                                    debugDescription:
                                        "All elements in array must have the same type"
                                ))
                        }
                    }
                    values.append(value)
                    buffer.value = .array(values, type: typeOfValue)
                }
            default:
                assertionFailure("Unkeyed container buffer was overwritten to non-array value")
                buffer.value = .array([value], type: elementType)
            }
            currentIndex += 1
        }

        mutating func encodeNil() throws {
            throw EncodingError.invalidValue(
                buffer,
                EncodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot encode nil value due to the type is unknown"
                )
            )
        }

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
            -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
        {
            do {
                let childBuffer = Buffer()
                try write(value: childBuffer)
                return KeyedEncodingContainer(
                    try KeyedContainer<NestedKey>(
                        codingPath: codingPath + [IndexKey(currentIndex)],
                        buffer: childBuffer,
                        bigQueryType: elementType,
                        userInfo: userInfo
                    )
                )
            } catch {
                return KeyedEncodingContainer(
                    ThrowingKeyedContainer<NestedKey>(
                        error: error,
                        codingPath: codingPath + [IndexKey(currentIndex)],
                        userInfo: userInfo
                    )
                )
            }
        }

        mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
            do {
                let childBuffer = Buffer()
                try write(value: childBuffer)
                return try UnkeyedContainer(
                    codingPath: codingPath + [IndexKey(currentIndex)],
                    buffer: childBuffer,
                    bigQueryType: elementType,
                    userInfo: userInfo
                )
            } catch {
                return ThrowingContainer(
                    error: error,
                    codingPath: codingPath + [IndexKey(currentIndex)],
                    userInfo: userInfo
                )
            }
        }

        mutating func superEncoder() -> any Swift.Encoder {
            fatalError("\(#function) has not been implemented")
        }

        mutating func encode(_ value: Bool) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: String) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: Double) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: Float) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: Int) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: Int8) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: Int16) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: Int32) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: Int64) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: UInt) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: UInt8) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: UInt16) throws {
            try write(value: Buffer(value: .actual(.init(value))))
        }

        mutating func encode(_ value: UInt32) throws {
            try write(value: Buffer(value: .actual(.init(value))))
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
            try write(value: Buffer(value: .actual(.init(Int64(value)))))
        }

        mutating func encode<T>(_ value: T) throws where T: Encodable {
            #if canImport(Foundation)
                if let date = value as? Date {
                    try write(value: Buffer(value: .actual(.init(date))))
                    return
                }
            #endif

            let encoder = Encoder(
                codingPath: codingPath,
                bigQueryType: elementType ?? (T.self as? QueryEncodable.Type)?.bigQueryType
            )
            try value.encode(to: encoder)
            try write(value: encoder.buffer)
        }
    }
}
