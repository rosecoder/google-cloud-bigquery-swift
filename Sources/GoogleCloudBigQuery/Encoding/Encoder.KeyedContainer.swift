#if canImport(Foundation)
  import Foundation
#endif

extension Encoder {

  struct KeyedContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    let codingPath: [CodingKey]
    let buffer: Encoder.Buffer
    let bigQueryType: BigQueryType?
    let userInfo: [CodingUserInfoKey: Any]

    init(
      codingPath: [CodingKey],
      buffer: Buffer,
      bigQueryType: BigQueryType?,
      userInfo: [CodingUserInfoKey: Any]
    ) throws {
      self.codingPath = codingPath
      self.buffer = buffer
      self.bigQueryType = bigQueryType
      self.userInfo = userInfo

      if let bigQueryType {
        switch bigQueryType {
        case .struct(let elementType):
          self.buffer.value = .struct(nil, type: elementType)
        default:
          throw EncodingError.invalidValue(
            buffer.value,
            EncodingError.Context(
              codingPath: codingPath,
              debugDescription:
                "Keyed container cannot be used for type \(bigQueryType)"
            )
          )
        }
      } else {
        self.buffer.value = .struct(nil, type: [:])
      }
    }

    private func write(value: Buffer, forKey key: Key) {
      switch buffer.value {
      case .struct(let values, var elementType):
        if bigQueryType != nil {
          if var values {
            values[key.stringValue] = value
            buffer.value = .struct(values, type: elementType)
          } else {
            buffer.value = .struct([key.stringValue: value], type: elementType)
          }
        } else {
          if var values {
            values[key.stringValue] = value
            elementType[key.stringValue] = value.type
            buffer.value = .struct(values, type: elementType)
          } else {
            elementType[key.stringValue] = value.type
            buffer.value = .struct([key.stringValue: value], type: elementType)
          }
        }
      default:
        assertionFailure("Keyed container buffer was overwritten to non-struct value")
        buffer.value = .struct([key.stringValue: value], type: [:])
      }
    }

    private func bigQueryType(forKey key: Key) -> BigQueryType? {
      if let bigQueryType {
        switch bigQueryType {
        case .struct(let elementType):
          return elementType[key.stringValue]
        default:
          preconditionFailure("Keyed container cannot be used for type \(bigQueryType)")
        }
      }
      return nil
    }

    mutating func encodeNil(forKey key: Key) throws {
      throw EncodingError.invalidValue(
        buffer,
        EncodingError.Context(
          codingPath: codingPath,
          debugDescription: "Cannot encode nil value due to the type is unknown"
        )
      )
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      do {
        let childBuffer = Buffer()
        write(value: childBuffer, forKey: key)
        return KeyedEncodingContainer(
          try KeyedContainer<NestedKey>(
            codingPath: codingPath + [key],
            buffer: childBuffer,
            bigQueryType: bigQueryType(forKey: key),
            userInfo: userInfo
          )
        )
      } catch {
        return KeyedEncodingContainer(
          ThrowingKeyedContainer<NestedKey>(
            error: error,
            codingPath: codingPath + [key],
            userInfo: userInfo
          )
        )
      }
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
      do {
        let childBuffer = Buffer()
        write(value: childBuffer, forKey: key)
        return try UnkeyedContainer(
          codingPath: codingPath + [key],
          buffer: childBuffer,
          bigQueryType: bigQueryType(forKey: key),
          userInfo: userInfo
        )
      } catch {
        return ThrowingContainer(
          error: error,
          codingPath: codingPath + [key],
          userInfo: userInfo
        )
      }
    }

    mutating func superEncoder() -> any Swift.Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func superEncoder(forKey key: Key) -> any Swift.Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value))), forKey: key)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
      if value > UInt64(Int64.max) {
        throw EncodingError.invalidValue(
          value,
          EncodingError.Context(
            codingPath: codingPath,
            debugDescription: "UInt64 is not yet supported"
          )
        )
      }
      write(value: Buffer(value: .actual(.init(Int64(value)))), forKey: key)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
      #if canImport(Foundation)
        if let date = value as? Date {
          write(value: Buffer(value: .actual(.init(date))), forKey: key)
          return
        }
      #endif

      let encoder = Encoder(
        codingPath: codingPath + [key],
        bigQueryType: bigQueryType(forKey: key)
          ?? (T.self as? QueryEncodable.Type)?.bigQueryType
          ?? BigQueryType(anySwiftType: T.self)
      )
      try value.encode(to: encoder)
      write(value: encoder.buffer, forKey: key)
    }
  }
}
