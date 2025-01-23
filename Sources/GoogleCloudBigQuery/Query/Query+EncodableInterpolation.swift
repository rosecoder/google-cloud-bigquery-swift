#if canImport(Foundation)
  import struct Foundation.Date
  import class Foundation.DateFormatter
  import struct Foundation.TimeZone

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS 'UTC'"
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter
  }()
#endif

extension Query.StringInterpolation {

  public mutating func appendInterpolation(_ value: Date) {
    description.append("?")
    parameters.append(.init(type: "TIMESTAMP", value: dateFormatter.string(from: value)))
  }

  public mutating func appendInterpolation(_ value: Date?) {
    description.append("?")
    parameters.append(.init(type: "TIMESTAMP", value: value.map(dateFormatter.string) ?? "NULL"))
  }

  public mutating func appendInterpolation(_ value: some Encodable) throws {
    description.append("?")

    let encoder = QueryEncoder(codingPath: [], elementType: nil)
    try value.encode(to: encoder)
    parameters.append(try map(buffer: encoder.buffer))
  }

  public mutating func appendInterpolation<Element: Encodable>(_ value: [Element]) throws {
    description.append("?")

    let encoder = QueryEncoder(
      codingPath: [],
      elementType: bigQueryTypeFromContainingArrayElement(arrayType: [Element].self)
    )
    try value.encode(to: encoder)
    parameters.append(try map(buffer: encoder.buffer))
  }

  private func map(buffer: QueryEncoder.Buffer) throws -> Query.Parameter {
    switch buffer.value {
    case .actual(let value):
      switch value {
      case .flat(let value, let type):
        return .init(type: type, value: value)
      case .array(let values, let elementType):
        return .init(type: "ARRAY", value: .array(values, elementType: elementType))
      case .struct(let values):
        return .init(type: "STRUCT", value: .struct(values))
      }

    case .buffer(let childBuffer):
      return try map(buffer: childBuffer)

    case .array(let array, let elementType):
      let values = try array.map(map)
      let resolvedElementType: Query.Parameter.Value
      if let elementType {
        resolvedElementType = elementType
      } else {
        guard let any = values.first else {
          throw EncodingError.invalidValue(
            buffer,
            EncodingError.Context(
              codingPath: [],  // TODO: Set somehow?
              debugDescription: "Unable to infer element type of array"
            ))
        }
        switch any.value {
        case .flat(_, let type):
          resolvedElementType = .flat("", type: type)
        case .array(_, let elementType):
          resolvedElementType = elementType
        case .struct(let values):
          resolvedElementType = .struct(values)
        }
      }
      return .init(
        type: "ARRAY",
        value: .array(values.map(\.value), elementType: resolvedElementType)
      )

    case .struct(let `struct`):
      return .init(
        type: "STRUCT",
        value: .struct(try `struct`.mapValues({ try map(buffer: $0).value }))
      )
    }
  }
}

private struct QueryEncoder: Swift.Encoder {

  let codingPath: [any CodingKey]
  let userInfo = [CodingUserInfoKey: Any]()
  let elementType: String?

  let buffer: QueryEncoder.Buffer = Buffer()

  init(codingPath: [any CodingKey], elementType: String?) {
    self.codingPath = codingPath
    self.elementType = elementType
  }

  final class Buffer {

    var value: Value

    enum Value {
      case actual(Query.Parameter.Value)

      case array([Buffer], type: Query.Parameter.Value?)
      case `struct`([String: Buffer])
      case buffer(Buffer)
    }

    init() {
      self.value = .actual(.flat("NULL", type: "ERR"))
    }

    init(value: Value) {
      self.value = value
    }
  }

  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
  where Key: CodingKey {
    KeyedEncodingContainer(KeyedContainer(codingPath: codingPath, buffer: buffer))
  }

  func unkeyedContainer() -> any UnkeyedEncodingContainer {
    UnkeyedContainer(
      codingPath: codingPath,
      buffer: buffer,
      elementType: elementType.map { .flat("", type: $0) }
    )
  }

  func singleValueContainer() -> any SingleValueEncodingContainer {
    SingleValueContainer(codingPath: codingPath, buffer: buffer)
  }

  struct SingleValueContainer: SingleValueEncodingContainer {

    let codingPath: [any CodingKey]
    let buffer: QueryEncoder.Buffer

    mutating func encodeNil() throws {
      buffer.value = .actual(.flat("NULL", type: "STRING"))
    }

    mutating func encode(_ value: Bool) throws {
      buffer.value = .actual(.flat(value ? "TRUE" : "FALSE", type: "BOOL"))
    }

    mutating func encode(_ value: String) throws {
      buffer.value = .actual(.flat(value, type: "STRING"))
    }

    mutating func encode(_ value: Double) throws {
      buffer.value = .actual(.flat(String(value), type: "FLOAT64"))
    }

    mutating func encode(_ value: Float) throws {
      buffer.value = .actual(.flat(String(value), type: "FLOAT64"))
    }

    mutating func encode(_ value: Int) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: Int8) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: Int16) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: Int32) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: Int64) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: UInt) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: UInt8) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: UInt16) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: UInt32) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode(_ value: UInt64) throws {
      buffer.value = .actual(.flat(String(value), type: "INT64"))
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
      #if canImport(Foundation)
        if let date = value as? Date {
          buffer.value = .actual(.flat(dateFormatter.string(from: date), type: "TIMESTAMP"))
          return
        }
      #endif

      let encoder = QueryEncoder(codingPath: codingPath, elementType: nil)
      try value.encode(to: encoder)
      buffer.value = encoder.buffer.value
    }
  }

  struct KeyedContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    let codingPath: [CodingKey]
    let buffer: QueryEncoder.Buffer

    init(codingPath: [CodingKey], buffer: Buffer) {
      self.codingPath = codingPath
      self.buffer = buffer
      self.buffer.value = .struct([:])
    }

    private func write(value: Buffer, forKey key: Key) {
      switch buffer.value {
      case .struct(var values):
        values[key.stringValue] = value
        buffer.value = .struct(values)
      default:
        assertionFailure("Keyed container buffer was overwritten to non-struct value")
        buffer.value = .struct([key.stringValue: value])
      }
    }

    mutating func encodeNil(forKey key: Key) {
      write(value: Buffer(), forKey: key)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let childBuffer = Buffer()
      write(value: childBuffer, forKey: key)
      return KeyedEncodingContainer(
        KeyedContainer<NestedKey>(codingPath: codingPath + [key], buffer: childBuffer)
      )
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
      let childBuffer = Buffer()
      write(value: childBuffer, forKey: key)
      return UnkeyedContainer(
        codingPath: codingPath + [key],
        buffer: childBuffer,
        elementType: nil
      )
    }

    mutating func superEncoder() -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }

    func encode(_ value: Bool, forKey key: Key) throws {
      write(
        value: Buffer(value: .actual(.flat(value ? "TRUE" : "FALSE", type: "BOOL"))), forKey: key)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(value, type: "STRING"))), forKey: key)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "FLOAT64"))), forKey: key)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "FLOAT64"))), forKey: key)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
      write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))), forKey: key)
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
      #if canImport(Foundation)
        if let date = value as? Date {
          write(
            value: Buffer(
              value: .actual(.flat(dateFormatter.string(from: date), type: "TIMESTAMP"))),
            forKey: key)
          return
        }
      #endif

      let encoder = QueryEncoder(
        codingPath: codingPath + [key],
        elementType: bigQueryTypeFromContainingArrayElement(arrayType: T.self)
      )
      try value.encode(to: encoder)
      write(value: encoder.buffer, forKey: key)
    }
  }

  struct UnkeyedContainer: UnkeyedEncodingContainer {

    var codingPath: [CodingKey]
    let buffer: QueryEncoder.Buffer
    let elementType: Query.Parameter.Value?

    var currentIndex: Int = -1

    var count: Int {
      currentIndex + 1
    }

    init(codingPath: [CodingKey], buffer: Buffer, elementType: Query.Parameter.Value?) {
      self.codingPath = codingPath
      self.buffer = buffer
      self.elementType = elementType
      self.buffer.value = .array([], type: elementType)
    }

    private mutating func write(value: Buffer) throws {
      switch buffer.value {
      case .array(var values, let elementType):
        let typeOfValue = type(of: value)
        if let typeOfValue, let any = values.first, let typeOfAny = type(of: any) {
          let isSameType = compareTypes(lhs: typeOfAny, rhs: typeOfValue)
          if !isSameType {
            throw EncodingError.invalidValue(
              value,
              EncodingError.Context(
                codingPath: codingPath,
                debugDescription: "All values must have the same type"
              ))
          }
        }
        values.append(value)
        buffer.value = .array(values, type: elementType ?? typeOfValue)
      default:
        assertionFailure("Unkeyed container buffer was overwritten to non-array value")
        buffer.value = .array([value], type: elementType)
      }
      currentIndex += 1
    }

    private func type(of buffer: Buffer) -> Query.Parameter.Value? {
      switch buffer.value {
      case .actual(let value):
        switch value {
        case .flat(_, let type):
          return .flat("", type: type)
        case .array(_, let elementType):
          return elementType
        case .struct(let values):
          return .struct(values)
        }
      case .array(_, let elementType):
        return elementType
      case .struct(let values):
        return .struct(values.compactMapValues { type(of: $0) })
      case .buffer(let childBuffer):
        return type(of: childBuffer)
      }
    }

    private func compareTypes(lhs: Query.Parameter.Value, rhs: Query.Parameter.Value) -> Bool {
      switch (lhs, rhs) {
      case (.flat(_, let lhsType), .flat(_, let rhsType)):
        return lhsType == rhsType
      case (.array(_, let lhsElementType), .array(_, let rhsElementType)):
        return compareTypes(lhs: lhsElementType, rhs: rhsElementType)
      case (.struct, .struct):
        return true  // TODO: Can we compare structs?
      default:
        return false
      }
    }

    mutating func encodeNil() throws {
      try write(value: Buffer())
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let childBuffer = Buffer()
      try! write(value: childBuffer)  // TODO: Handle error
      return KeyedEncodingContainer(
        KeyedContainer<NestedKey>(
          codingPath: codingPath + [IndexKey(currentIndex)],
          buffer: childBuffer
        )
      )
    }

    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
      let childBuffer = Buffer()
      try! write(value: childBuffer)  // TODO: Handle error
      return UnkeyedContainer(
        codingPath: codingPath + [IndexKey(currentIndex)],
        buffer: childBuffer,
        elementType: nil
      )
    }

    mutating func superEncoder() -> any Encoder {
      fatalError("\(#function) has not been implemented")
    }

    mutating func encode(_ value: Bool) throws {
      try write(value: Buffer(value: .actual(.flat(value ? "TRUE" : "FALSE", type: "BOOL"))))
    }

    mutating func encode(_ value: String) throws {
      try write(value: Buffer(value: .actual(.flat(value, type: "STRING"))))
    }

    mutating func encode(_ value: Double) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "FLOAT64"))))
    }

    mutating func encode(_ value: Float) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "FLOAT64"))))
    }

    mutating func encode(_ value: Int) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: Int8) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: Int16) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: Int32) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: Int64) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: UInt) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: UInt8) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: UInt16) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: UInt32) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode(_ value: UInt64) throws {
      try write(value: Buffer(value: .actual(.flat(String(value), type: "INT64"))))
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
      #if canImport(Foundation)
        if let date = value as? Date {
          try write(
            value: Buffer(
              value: .actual(.flat(dateFormatter.string(from: date), type: "TIMESTAMP"))))
          return
        }
      #endif

      let encoder = QueryEncoder(codingPath: codingPath, elementType: nil)
      try value.encode(to: encoder)
      try write(value: encoder.buffer)
    }
  }
}

private func bigQueryTypeFromContainingArrayElement<Element: Encodable>(
  arrayType type: Element.Type
) -> String? {
  if type == [Int].self {
    return "INT64"
  }
  if type == [Int8].self {
    return "INT64"
  }
  if type == [Int16].self {
    return "INT64"
  }
  if type == [Int32].self {
    return "INT64"
  }
  if type == [Int64].self {
    return "INT64"
  }
  if type == [UInt].self {
    return "INT64"
  }
  if type == [UInt8].self {
    return "INT64"
  }
  if type == [UInt16].self {
    return "INT64"
  }
  if type == [UInt32].self {
    return "INT64"
  }
  if type == [UInt64].self {
    return "INT64"
  }
  if type == [Float].self {
    return "FLOAT64"
  }
  if type == [Double].self {
    return "FLOAT64"
  }
  if type == [String].self {
    return "STRING"
  }
  if type == [Bool].self {
    return "BOOL"
  }
  return nil
}
