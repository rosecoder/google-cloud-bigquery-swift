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
public struct Query {

  /// A query string to execute, using GoogleSQL syntax. Example: `"SELECT COUNT(f1) FROM myProjectId.myDatasetId.myTableId"`.
  public let sql: String

  /// The maximum number of rows of data to return per page of results. Setting this flag to a small value such as 1000 and then paging through results might improve reliability when the query result set is large. In addition to this limit, responses are also limited to 10 MB. By default, there is no maximum row count, and only the byte limit applies.
  public let maxResults: UInt32?

  /// Initializes a new `Query` with the given SQL and optional maximum number of results.
  public init(sql: StaticString, maxResults: UInt32? = nil) {
    self.sql = String(describing: sql)
    self.maxResults = maxResults
  }

  /// Initializes a new `Query` with the given SQL and optional maximum number of results.
  ///
  /// - Warning: This initializer is unsafe and should only be used when you are sure that the SQL is safe.
  public init(unsafeSQL sql: String, maxResults: UInt32? = nil) {
    self.sql = sql
    self.maxResults = maxResults
  }
}

extension Query: ExpressibleByStringLiteral {

  public typealias StringLiteralType = StaticString

  public init(stringLiteral value: StaticString) {
    self.sql = String(describing: value)
    self.maxResults = nil
  }
}

extension Query: ExpressibleByStringInterpolation {

  public init(stringInterpolation: StringInterpolation) {
    self.sql = stringInterpolation.description
    self.maxResults = nil
  }

  public struct StringInterpolation: StringInterpolationProtocol {

    var description: String

    public init(literalCapacity: Int, interpolationCount: Int) {
      self.description = ""
    }

    public mutating func appendLiteral(_ literal: StaticString) {
      description.append(String(describing: literal))
    }

    public mutating func appendInterpolation(_ value: StaticString) {
      description.append(String(describing: value))
    }

    public mutating func appendLiteral(unsafe literal: String) {
      description.append(literal)
    }

    public mutating func appendInterpolation(unsafe value: String) {
      description.append(value)
    }
  }
}
