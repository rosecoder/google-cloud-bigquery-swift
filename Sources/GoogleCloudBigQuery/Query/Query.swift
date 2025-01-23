/// A BigQuery SQL query.
///
/// You can create a query directly from a string literal:
/// ```swift
/// let query: Query = "SELECT * FROM `my-project.my_dataset.my_table`"
/// ```
///
/// Or construct it with parameters:
/// ```swift
/// let query = Query(
///     sql: "SELECT * FROM `my-project.my_dataset.my_table` LIMIT @limit",
///     maxResults: 100
/// )
/// ```
public struct Query: Sendable {

  /// A query string to execute, using GoogleSQL syntax. Example: `"SELECT COUNT(f1) FROM myProjectId.myDatasetId.myTableId"`.
  public var sql: String

  /// Query parameters for the SQL.
  public var parameters: [Parameter]

  /// The maximum number of rows of data to return per page of results. Setting this flag to a small value such as 1000 and then paging through results might improve reliability when the query result set is large. In addition to this limit, responses are also limited to 10 MB. By default, there is no maximum row count, and only the byte limit applies.
  public var maxResults: UInt32?

  /// Initializes a new `Query` with the given SQL and optional maximum number of results.
  public init(sql: StaticString, parameters: [Parameter] = [], maxResults: UInt32? = nil) {
    self.sql = String(describing: sql)
    self.parameters = parameters
    self.maxResults = maxResults
  }

  /// Initializes a new `Query` with the given SQL and optional maximum number of results.
  ///
  /// - Warning: This initializer is unsafe and should only be used when you are sure that the SQL is safe.
  public init(unsafeSQL sql: String, parameters: [Parameter] = [], maxResults: UInt32? = nil) {
    self.sql = sql
    self.parameters = parameters
    self.maxResults = maxResults
  }
}

extension Query {

  /// A query parameter.
  ///
  /// See data types: https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types. Note that struct and array needs generics specified: https://cloud.google.com/bigquery/docs/parameterized-queries#using_structs_in_parameterized_queries
  public struct Parameter: Sendable, Equatable {

    /// The value of the parameter casted to a string.
    public var value: Value

    public init(type: String, value: String) {
      self.value = .flat(value, type: type)
    }

    public init(type: String, value: Value) {
      self.value = value
    }

    public enum Value: Sendable, Equatable {
      case flat(String, type: String)
      case array([Value], elementType: String)
      case `struct`([String: Value])
    }
  }
}

extension Query: ExpressibleByStringLiteral {

  public typealias StringLiteralType = StaticString

  public init(stringLiteral value: StaticString) {
    self.sql = String(describing: value)
    self.parameters = []
    self.maxResults = nil
  }
}

extension Query: ExpressibleByStringInterpolation {

  public init(stringInterpolation: StringInterpolation) {
    self.sql = stringInterpolation.description
    self.parameters = stringInterpolation.parameters
    self.maxResults = nil
  }

  public struct StringInterpolation: StringInterpolationProtocol, Sendable {

    var description: String
    var parameters: [Parameter]

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

    public mutating func appendInterpolation(_ value: String) {
      description.append("?")
      parameters.append(.init(type: "STRING", value: value))
    }

    public mutating func appendInterpolation(_ value: Int) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: Int8) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: Int16) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: Int32) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: Int64) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: UInt) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: UInt8) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: UInt16) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: UInt32) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: UInt64) {
      description.append("?")
      parameters.append(.init(type: "INT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: Float) {
      description.append("?")
      parameters.append(.init(type: "FLOAT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: Double) {
      description.append("?")
      parameters.append(.init(type: "FLOAT64", value: String(value)))
    }

    public mutating func appendInterpolation(_ value: Bool) {
      description.append("?")
      parameters.append(.init(type: "BOOL", value: value ? "TRUE" : "FALSE"))
    }
  }
}
