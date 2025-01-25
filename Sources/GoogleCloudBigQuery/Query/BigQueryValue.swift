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

    public var storage: Storage
    public var type: BigQueryType

    public init(stringValue: String?, type: BigQueryType) {
        self.storage = .string(stringValue)
        self.type = type
    }

    public init(value: Storage, type: BigQueryType) {
        self.storage = value
        self.type = type
    }

    public indirect enum Storage: Sendable, Equatable {
        case string(String?)
        case array([BigQueryValue])
        case `struct`(OrderedDictionary<String, BigQueryValue>?)
    }
}

extension BigQueryValue {

    public init(_ value: Bool?) {
        self.init(stringValue: value.map { $0 ? "TRUE" : "FALSE" }, type: .bool)
    }

    public init(_ value: String?) {
        self.init(stringValue: value, type: .string)
    }

    public init(_ value: Double?) {
        self.init(stringValue: value.map { String($0) }, type: .float64)
    }

    public init(_ value: Float?) {
        self.init(stringValue: value.map { String($0) }, type: .float64)
    }

    public init(_ value: Int?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: Int8?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: Int16?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: Int32?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: Int64?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: UInt?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: UInt8?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: UInt16?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: UInt32?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    public init(_ value: UInt64?) {
        self.init(stringValue: value.map { String($0) }, type: .int64)
    }

    #if canImport(Foundation)
        public init(_ value: Date?) {
            self.init(stringValue: value.map { dateFormatter.string(from: $0) }, type: .timestamp)
        }
    #endif
}
