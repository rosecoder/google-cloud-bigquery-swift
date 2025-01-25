import OrderedCollections

#if canImport(Foundation)
  import struct Foundation.Date
#endif

extension Query: ExpressibleByStringInterpolation {

  public init(stringInterpolation: StringInterpolation) {
    self.sql = stringInterpolation.description
    self.parameters = stringInterpolation.parameters
    self.maxResults = nil
  }

  public struct StringInterpolation: StringInterpolationProtocol, Sendable {

    var description: String
    var parameters: [BigQueryValue]

    public init(literalCapacity: Int, interpolationCount: Int) {
      self.description = ""
      self.description.reserveCapacity(literalCapacity + interpolationCount)

      self.parameters = []
      self.parameters.reserveCapacity(interpolationCount)
    }

    public mutating func appendLiteral(_ literal: StaticString) {
      description.append(String(describing: literal))
    }

    public mutating func appendInterpolation(unsafe value: String) {
      description.append(value)
    }

    // Note: We are providing a optional and non-optional version of each type to favor this over the `some Encoder` version
    // which throws. This also fixes issue where we must know the type of nullable values which isn't possible using encodable.

    public mutating func appendInterpolation(_ value: String) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: String?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int8) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int8?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int16) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int16?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int32) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int32?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int64) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Int64?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt8) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt8?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt16) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt16?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt32) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt32?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt64) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: UInt64?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Float) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Float?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Double) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Double?) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Bool) {
      append(value: .init(value))
    }

    public mutating func appendInterpolation(_ value: Bool?) {
      append(value: .init(value))
    }

    #if canImport(Foundation)
      public mutating func appendInterpolation(_ value: Date) {
        append(value: .init(value))
      }

      public mutating func appendInterpolation(_ value: Date?) {
        append(value: .init(value))
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
      let encoder = Encoder(for: Element.self)
      try value.encode(to: encoder)
      append(value: try encoder.bigQueryValue())
    }

    private mutating func append(value: BigQueryValue) {
      description.append("?")
      parameters.append(value)
    }
  }
}
