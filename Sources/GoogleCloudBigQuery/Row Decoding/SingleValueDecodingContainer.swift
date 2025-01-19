import SwiftProtobuf

#if canImport(Foundation)
  import struct Foundation.Date
#endif

extension RowDecoder {

  struct SingleValueContainer: SingleValueDecodingContainer, Swift.Decoder {

    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any] = [:]

    // MARK: - SingleValueDecodingContainer

    let raw: Google_Protobuf_Value?

    private var kind: Google_Protobuf_Value.OneOf_Kind {
      raw?.kind ?? .nullValue(.nullValue)
    }

    func decodeNil() -> Bool {
      kind == .nullValue(.nullValue)
    }

    func decode(_ type: Bool.Type) throws -> Bool {
      switch kind {
      case .nullValue:
        return false
      case .numberValue(let value):
        return value > 0
      case .stringValue(let value):
        return !value.isEmpty
      case .boolValue(let value):
        return value
      case .structValue, .listValue:
        throw UndecodableTypeError(codingPath: codingPath, expectedKind: kind)
      }
    }

    func decode(_ type: String.Type) throws -> String {
      switch kind {
      case .nullValue:
        return ""
      case .stringValue(let value):
        return value
      case .boolValue(let value):
        return value ? "true" : "false"
      case .numberValue(let value):
        return String(value)
      case .structValue, .listValue:
        throw UndecodableTypeError(codingPath: codingPath, expectedKind: kind)
      }
    }

    func decode(_ type: Double.Type) throws -> Double {
      switch kind {
      case .nullValue:
        return 0
      case .numberValue(let value):
        return value
      case .stringValue(let value):
        guard let parsed = Double(value) else {
          throw UndecodableTypeError(codingPath: codingPath, expectedKind: kind)
        }
        return parsed
      case .boolValue(let value):
        return value ? 1 : 0
      case .structValue, .listValue:
        throw UndecodableTypeError(codingPath: codingPath, expectedKind: kind)
      }
    }

    func decode(_ type: Float.Type) throws -> Float {
      Float(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: Int.Type) throws -> Int {
      Int(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
      Int8(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
      Int16(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
      Int32(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
      Int64(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: UInt.Type) throws -> UInt {
      UInt(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
      UInt8(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
      UInt16(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
      UInt32(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
      UInt64(try decode(Double.self))  // TODO: Add bounds check
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      switch type {
      #if canImport(Foundation)
        case is Date.Type:
          switch kind {
          case .numberValue(let value):
            return Date(timeIntervalSince1970: value) as! T
          default:
            throw UndecodableTypeError(codingPath: codingPath, expectedKind: kind)
          }
      #endif
      default:
        return try T.init(from: self)
      }
    }

    // MARK: - Decoder

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
    where Key: CodingKey {
      switch kind {
      case .structValue(let `struct`):
        return KeyedDecodingContainer(
          KeyedContainer<Key>(
            codingPath: codingPath,
            fields: `struct`.fields
          ))
      default:
        throw UndecodableTypeError(codingPath: codingPath, expectedKind: kind)
      }
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      switch kind {
      case .listValue(let list):
        return UnkeyedContainer(
          codingPath: codingPath,
          values: list.values
        )
      default:
        throw UndecodableTypeError(codingPath: codingPath, expectedKind: kind)
      }
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
      self
    }
  }
}
