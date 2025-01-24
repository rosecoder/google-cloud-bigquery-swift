import OrderedCollections

#if canImport(Foundation)
  import struct Foundation.Date
#endif

extension Query.StringInterpolation {

  #if canImport(Foundation)
    public mutating func appendInterpolation(_ value: Date) {
      description.append("?")
      parameters.append(.init(value: value))
    }

    public mutating func appendInterpolation(_ value: Date?) {
      description.append("?")
      parameters.append(.init(value: value))
    }
  #endif

  public mutating func appendInterpolation<Element: Encodable>(_ value: Element) throws {
    try append(value)
  }

  public mutating func appendInterpolation<Element: Encodable>(_ value: Element?) throws {
    try append(value)
  }

  public mutating func appendInterpolation<Element: Encodable>(_ value: [Element]) throws {
    try append(value)
  }

  public mutating func appendInterpolation<Element: Encodable>(_ value: [Element]?) throws {
    try append(value)
  }

  private mutating func append<Element: Encodable>(_ value: Element) throws {
    description.append("?")

    let encoder = QueryEncoder(
      codingPath: [],
      bigQueryType: (Element.self as? QueryEncodable.Type)?.bigQueryType
        ?? resolveBigQueryType(anySwiftType: Element.self)
    )
    try value.encode(to: encoder)
    parameters.append(try map(buffer: encoder.buffer))
  }

  private func map(buffer: QueryEncoder.Buffer) throws -> Query.Parameter {
    switch buffer.value {
    case .actual(let value):
      return value

    case .buffer(let childBuffer):
      return try map(buffer: childBuffer)

    case .array(let array, let elementType):
      let resolvedElementType: BigQueryType
      if let elementType {
        resolvedElementType = elementType
      } else {
        guard let anyElement = array.first else {
          throw EncodingError.invalidValue(
            buffer,
            EncodingError.Context(
              codingPath: [],  // TODO: Set somehow?
              debugDescription: "Unable to infer element type of array"
            ))
        }
        guard let anyElementType = anyElement.type else {
          throw EncodingError.invalidValue(
            buffer,
            EncodingError.Context(
              codingPath: [],  // TODO: Set somehow?
              debugDescription: "Unable to infer element type of array"
            ))
        }
        resolvedElementType = anyElementType
      }
      return .init(
        value: .array(try array.map({ try map(buffer: $0).value })),
        type: .array(resolvedElementType)
      )

    case .struct(let `struct`, let elementType):
      return .init(
        value: .struct(try `struct`?.mapValues({ try map(buffer: $0).value })),
        type: .struct(elementType)
      )
    }
  }
}

private struct QueryEncoder: Swift.Encoder {

  let codingPath: [any CodingKey]
  let userInfo = [CodingUserInfoKey: Any]()
  let bigQueryType: BigQueryType?

  let buffer: QueryEncoder.Buffer = Buffer()

  init(
    codingPath: [any CodingKey],
    bigQueryType: BigQueryType?
  ) {
    self.codingPath = codingPath
    self.bigQueryType = bigQueryType
  }

  final class Buffer {

    var value: Value

    enum Value {
      case actual(Query.Parameter)

      case array([Buffer], type: BigQueryType?)
      case `struct`(
        OrderedDictionary<String, Buffer>?, type: OrderedDictionary<String, BigQueryType>)
      case buffer(Buffer)
    }

    init() {
      self.value = .actual(.init(value: nil, type: .string))  // TODO: Throw somewhere if this is never overwritten?
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

  struct SingleValueContainer: SingleValueEncodingContainer {

    let codingPath: [any CodingKey]
    let buffer: QueryEncoder.Buffer
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
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: String) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: Double) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: Float) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: Int) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: Int8) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: Int16) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: Int32) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: Int64) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: UInt) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: UInt8) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: UInt16) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: UInt32) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode(_ value: UInt64) throws {
      buffer.value = .actual(.init(value: value))
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
      #if canImport(Foundation)
        if let date = value as? Date {
          buffer.value = .actual(.init(value: date))
          return
        }
      #endif

      let encoder = QueryEncoder(
        codingPath: codingPath,
        bigQueryType: bigQueryType
          ?? (T.self as? QueryEncodable.Type)?.bigQueryType
          ?? resolveBigQueryType(anySwiftType: T.self)
      )
      try value.encode(to: encoder)
      buffer.value = encoder.buffer.value
    }
  }

  struct KeyedContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    let codingPath: [CodingKey]
    let buffer: QueryEncoder.Buffer
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

    mutating func superEncoder() -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.init(value: value))), forKey: key)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
      #if canImport(Foundation)
        if let date = value as? Date {
          write(value: Buffer(value: .actual(.init(value: date))), forKey: key)
          return
        }
      #endif

      let encoder = QueryEncoder(
        codingPath: codingPath + [key],
        bigQueryType: bigQueryType(forKey: key)
          ?? (T.self as? QueryEncodable.Type)?.bigQueryType
          ?? resolveBigQueryType(anySwiftType: T.self)
      )
      try value.encode(to: encoder)
      write(value: encoder.buffer, forKey: key)
    }
  }

  struct UnkeyedContainer: UnkeyedEncodingContainer {

    var codingPath: [CodingKey]
    let buffer: QueryEncoder.Buffer
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
                  debugDescription: "All elements in array must have the same type"
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

    mutating func superEncoder() -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func encode(_ value: Bool) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: String) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: Double) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: Float) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: Int) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: Int8) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: Int16) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: Int32) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: Int64) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: UInt) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: UInt8) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: UInt16) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: UInt32) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode(_ value: UInt64) throws {
      try write(value: Buffer(value: .actual(.init(value: value))))
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
      #if canImport(Foundation)
        if let date = value as? Date {
          try write(value: Buffer(value: .actual(.init(value: date))))
          return
        }
      #endif

      let encoder = QueryEncoder(
        codingPath: codingPath,
        bigQueryType: elementType ?? (T.self as? QueryEncodable.Type)?.bigQueryType
      )
      try value.encode(to: encoder)
      try write(value: encoder.buffer)
    }
  }

  private struct ThrowingContainer: Encoder, SingleValueEncodingContainer, UnkeyedEncodingContainer
  {

    let error: Error
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]

    var count: Int { 0 }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
    where Key: CodingKey {
      KeyedEncodingContainer(
        ThrowingKeyedContainer<Key>(error: error, codingPath: codingPath, userInfo: userInfo)
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
        ThrowingKeyedContainer<NestedKey>(error: error, codingPath: codingPath, userInfo: userInfo)
      )
    }

    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
      ThrowingContainer(error: error, codingPath: codingPath, userInfo: userInfo)
    }

    mutating func superEncoder() -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }
  }

  private struct ThrowingKeyedContainer<Key>: KeyedEncodingContainerProtocol
  where Key: CodingKey {

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

    mutating func superEncoder() -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }
  }
}

private func resolveBigQueryType<Element: Encodable>(
  anySwiftType type: Element.Type
) -> BigQueryType? {
  if type == Int.self {
    return .int64
  }
  if type == Int8.self {
    return .int64
  }
  if type == Int16.self {
    return .int64
  }
  if type == Int32.self {
    return .int64
  }
  if type == Int64.self {
    return .int64
  }
  if type == UInt.self {
    return .int64
  }
  if type == UInt8.self {
    return .int64
  }
  if type == UInt16.self {
    return .int64
  }
  if type == UInt32.self {
    return .int64
  }
  if type == UInt64.self {
    return .int64
  }
  if type == Float.self {
    return .float64
  }
  if type == Double.self {
    return .float64
  }
  if type == String.self {
    return .string
  }
  if type == Bool.self {
    return .bool
  }
  if type == [Int].self {
    return .array(.int64)
  }
  if type == [Int8].self {
    return .array(.int64)
  }
  if type == [Int16].self {
    return .array(.int64)
  }
  if type == [Int32].self {
    return .array(.int64)
  }
  if type == [Int64].self {
    return .array(.int64)
  }
  if type == [UInt].self {
    return .array(.int64)
  }
  if type == [UInt8].self {
    return .array(.int64)
  }
  if type == [UInt16].self {
    return .array(.int64)
  }
  if type == [UInt32].self {
    return .array(.int64)
  }
  if type == [UInt64].self {
    return .array(.int64)
  }
  if type == [Float].self {
    return .array(.float64)
  }
  if type == [Double].self {
    return .array(.float64)
  }
  if type == [String].self {
    return .array(.string)
  }
  if type == [Bool].self {
    return .array(.bool)
  }
  return nil
}
