struct Encoder: Swift.Encoder {

  let codingPath: [any CodingKey]
  let userInfo = [CodingUserInfoKey: Any]()
  let bigQueryType: BigQueryType?

  let buffer: Encoder.Buffer = Buffer()

  init<Element: Encodable>(for element: Element.Type) {
    self.codingPath = []
    self.bigQueryType =
      (Element.self as? QueryEncodable.Type)?.bigQueryType
      ?? BigQueryType(anySwiftType: Element.self)
  }

  init(
    codingPath: [any CodingKey],
    bigQueryType: BigQueryType?
  ) {
    self.codingPath = codingPath
    self.bigQueryType = bigQueryType
  }

  func bigQueryValue() throws -> BigQueryValue {
    try buffer.bigQueryValue()
  }

  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
  where Key: CodingKey {
    do {
      return KeyedEncodingContainer(
        try KeyedContainer(
          codingPath: codingPath,
          buffer: buffer,
          bigQueryType: bigQueryType,
          userInfo: userInfo
        )
      )
    } catch {
      return KeyedEncodingContainer(
        ThrowingKeyedContainer(
          error: error,
          codingPath: codingPath,
          userInfo: userInfo
        )
      )
    }
  }

  func unkeyedContainer() -> any UnkeyedEncodingContainer {
    do {
      return try UnkeyedContainer(
        codingPath: codingPath,
        buffer: buffer,
        bigQueryType: bigQueryType,
        userInfo: userInfo
      )
    } catch {
      return ThrowingContainer(
        error: error,
        codingPath: codingPath,
        userInfo: userInfo
      )
    }
  }

  func singleValueContainer() -> any SingleValueEncodingContainer {
    SingleValueContainer(
      codingPath: codingPath,
      buffer: buffer,
      bigQueryType: bigQueryType
    )
  }
}
