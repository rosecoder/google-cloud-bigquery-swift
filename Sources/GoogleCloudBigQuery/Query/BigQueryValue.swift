import OrderedCollections

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

/// A query parameter.
///
/// See data types: https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types. Note that struct and array needs generics specified: https://cloud.google.com/bigquery/docs/parameterized-queries#using_structs_in_parameterized_queries
public struct BigQueryValue: Sendable, Equatable {

  var storage: Storage
  var type: BigQueryType

  init(value: Storage, type: BigQueryType) {
    self.storage = value
    self.type = type
  }

  indirect enum Storage: Sendable, Equatable {
    case string(String?)
    case bool(Bool?)
    case int64(Int64?)
    case float64(Double?)
    #if canImport(Foundation)
      case timestamp(Date?)
    #endif
    case array([BigQueryValue])
    case `struct`(OrderedDictionary<String, BigQueryValue>?)
  }
}

extension BigQueryValue {

  public init(_ value: Bool?) {
    self.init(value: .bool(value), type: .bool)
  }

  public init(_ value: String?) {
    self.init(value: .string(value), type: .string)
  }

  public init(_ value: Double?) {
    self.init(value: .float64(value), type: .float64)
  }

  public init(_ value: Float?) {
    self.init(value: .float64(value.map { Double($0) }), type: .float64)
  }

  public init(_ value: Int?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  public init(_ value: Int8?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  public init(_ value: Int16?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  public init(_ value: Int32?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  public init(_ value: Int64?) {
    self.init(value: .int64(value), type: .int64)
  }

  public init(_ value: UInt?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  public init(_ value: UInt8?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  public init(_ value: UInt16?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  public init(_ value: UInt32?) {
    self.init(value: .int64(value.map { Int64($0) }), type: .int64)
  }

  #if canImport(Foundation)
    public init(_ value: Date?) {
      self.init(value: .timestamp(value), type: .timestamp)
    }
  #endif
}
