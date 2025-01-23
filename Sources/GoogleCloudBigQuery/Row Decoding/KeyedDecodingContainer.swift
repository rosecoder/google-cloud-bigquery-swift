import SwiftProtobuf

extension RowDecoder {

  struct KeyedContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {

    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    let fields: [String: Google_Protobuf_Value]

    // MARK: - Nested containers

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws
      -> KeyedDecodingContainer<NestedKey>
    where NestedKey: CodingKey {
      let kind = fields[key.stringValue]?.kind
      switch kind {
      case .structValue(let `struct`):
        return KeyedDecodingContainer(
          KeyedContainer<NestedKey>(
            codingPath: codingPath + [key],
            userInfo: userInfo,
            fields: `struct`.fields
          ))
      default:
        throw UndecodableTypeError(codingPath: codingPath + [key], expectedKind: kind)
      }
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      let kind = fields[key.stringValue]?.kind
      switch kind {
      case .listValue(let list):
        return UnkeyedContainer(
          codingPath: codingPath + [key],
          userInfo: userInfo,
          values: list.values
        )
      default:
        throw UndecodableTypeError(codingPath: codingPath + [key], expectedKind: kind)
      }
    }

    // MARK: - Decoder

    func superDecoder() throws -> Swift.Decoder {
      fatalError("\(#function) has not been implemented")
    }

    func superDecoder(forKey key: Key) throws -> Swift.Decoder {
      fatalError("\(#function) has not been implemented")
    }

    // MARK: - Decode

    var allKeys: [Key] {
      fields.keys.map { Key.init(stringValue: $0)! }
    }

    func contains(_ key: Key) -> Bool {
      fields.keys.contains(key.stringValue)
    }

    private func singleValueContainer(forKey key: Key) throws -> SingleValueContainer {
      SingleValueContainer(
        codingPath: codingPath + [key],
        userInfo: userInfo,
        raw: fields[key.stringValue]
      )
    }

    func decodeNil(forKey key: Key) throws -> Bool {
      try singleValueContainer(forKey: key).decodeNil()
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      try singleValueContainer(forKey: key).decode(Bool.self)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
      try singleValueContainer(forKey: key).decode(String.self)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      try singleValueContainer(forKey: key).decode(Double.self)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      try singleValueContainer(forKey: key).decode(Float.self)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      try singleValueContainer(forKey: key).decode(Int.self)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      try singleValueContainer(forKey: key).decode(Int8.self)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      try singleValueContainer(forKey: key).decode(Int16.self)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      try singleValueContainer(forKey: key).decode(Int32.self)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      try singleValueContainer(forKey: key).decode(Int64.self)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      try singleValueContainer(forKey: key).decode(UInt.self)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      try singleValueContainer(forKey: key).decode(UInt8.self)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      try singleValueContainer(forKey: key).decode(UInt16.self)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      try singleValueContainer(forKey: key).decode(UInt32.self)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      try singleValueContainer(forKey: key).decode(UInt64.self)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
      return try singleValueContainer(forKey: key).decode(type)
    }
  }
}
