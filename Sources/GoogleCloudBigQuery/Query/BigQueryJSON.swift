#if canImport(Foundation)
  import class Foundation.JSONEncoder
#endif

/// A value of the BigQuery `JSON` type.
///
/// See: https://cloud.google.com/bigquery/docs/json-data
public struct BigQueryJSON: Sendable, Equatable, QueryEncodable {

  public static var bigQueryType: BigQueryType { .json }

  /// The JSON text of the value.
  public var text: String

  /// Creates a value from already serialized JSON text.
  public init(text: String) {
    self.text = text
  }

  #if canImport(Foundation)
    /// Creates a value by serializing an `Encodable` value to JSON text.
    public init<Value: Encodable>(_ value: Value) throws {
      self.text = String(decoding: try JSONEncoder().encode(value), as: UTF8.self)
    }
  #endif

  public func encode(to encoder: any Swift.Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(text)
  }
}
