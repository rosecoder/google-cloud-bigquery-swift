extension Encoder {

  struct ThrowingContainer: Swift.Encoder, SingleValueEncodingContainer,
    UnkeyedEncodingContainer
  {

    let error: Error
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]

    var count: Int { 0 }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
    where Key: CodingKey {
      KeyedEncodingContainer(
        ThrowingKeyedContainer<Key>(
          error: error, codingPath: codingPath, userInfo: userInfo)
      )
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {
      ThrowingContainer(error: error, codingPath: codingPath, userInfo: userInfo)
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
      ThrowingContainer(error: error, codingPath: codingPath, userInfo: userInfo)
    }

    mutating func encodeNil() throws {
      throw error
    }

    mutating func encode(_ value: Bool) throws {
      throw error
    }

    mutating func encode(_ value: String) throws {
      throw error
    }

    mutating func encode(_ value: Double) throws {
      throw error
    }

    mutating func encode(_ value: Float) throws {
      throw error
    }

    mutating func encode(_ value: Int) throws {
      throw error
    }

    mutating func encode(_ value: Int8) throws {
      throw error
    }

    mutating func encode(_ value: Int16) throws {
      throw error
    }

    mutating func encode(_ value: Int32) throws {
      throw error
    }

    mutating func encode(_ value: Int64) throws {
      throw error
    }

    mutating func encode(_ value: UInt) throws {
      throw error
    }

    mutating func encode(_ value: UInt8) throws {
      throw error
    }

    mutating func encode(_ value: UInt16) throws {
      throw error
    }

    mutating func encode(_ value: UInt32) throws {
      throw error
    }

    mutating func encode(_ value: UInt64) throws {
      throw error
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
      throw error
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      KeyedEncodingContainer(
        ThrowingKeyedContainer<NestedKey>(
          error: error, codingPath: codingPath, userInfo: userInfo)
      )
    }

    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
      ThrowingContainer(error: error, codingPath: codingPath, userInfo: userInfo)
    }

    mutating func superEncoder() -> any Swift.Encoder {
      fatalError("\(#function) has not been implemented")
    }
  }

  struct ThrowingKeyedContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    let error: Error
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]

    mutating func encodeNil(forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
      throw error
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
      throw error
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
      throw error
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      KeyedEncodingContainer(
        ThrowingKeyedContainer<NestedKey>(
          error: error, codingPath: codingPath + [key], userInfo: userInfo)
      )
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
      ThrowingContainer(error: error, codingPath: codingPath + [key], userInfo: userInfo)
    }

    mutating func superEncoder() -> any Swift.Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func superEncoder(forKey key: Key) -> any Swift.Encoder {
      fatalError("\(#function) has not been implemented")
    }
  }
}
