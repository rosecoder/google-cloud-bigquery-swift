import OrderedCollections

#if canImport(Foundation)
  import struct Foundation.Date
#endif

/// A BigQuery SQL query.
///
/// You can create a query directly from a string literal:
/// ```swift
/// let query: Query = "SELECT * FROM `my-project.my_dataset.my_table`"
/// ```
///
/// Or construct it with parameters:
/// ```swift
/// let query: Query = "SELECT * FROM `my-project.my_dataset.my_table` WHERE id = \(id)"
/// ```
public struct Query: Sendable {

  /// A query string to execute, using GoogleSQL syntax. Example: `"SELECT COUNT(f1) FROM myProjectId.myDatasetId.myTableId"`.
  public var sql: String

  /// Query parameters for the SQL.
  public var parameters: [BigQueryValue]

  /// The maximum number of rows of data to return per page of results. Setting this flag to a small value such as 1000 and then paging through results might improve reliability when the query result set is large. In addition to this limit, responses are also limited to 10 MB. By default, there is no maximum row count, and only the byte limit applies.
  public var maxResults: UInt32?

  /// How long each request waits for the query to complete before asking again. This doesn't limit the total duration of the query – the query is always waited for until it completes. BigQuery may respond earlier than requested, typically after around 200 seconds.
  public var timeout: Duration = .seconds(10)

  /// Initializes a new `Query` with the given SQL and optional maximum number of results.
  public init(
    sql: StaticString,
    parameters: [BigQueryValue] = [],
    maxResults: UInt32? = nil,
    timeout: Duration = .seconds(10)
  ) {
    self.sql = String(describing: sql)
    self.parameters = parameters
    self.maxResults = maxResults
    self.timeout = timeout
  }

  /// Initializes a new `Query` with the given SQL and optional maximum number of results.
  ///
  /// - Warning: This initializer is unsafe and should only be used when you are sure that the SQL is safe.
  public init(
    unsafeSQL sql: String,
    parameters: [BigQueryValue] = [],
    maxResults: UInt32? = nil,
    timeout: Duration = .seconds(10)
  ) {
    self.sql = sql
    self.parameters = parameters
    self.maxResults = maxResults
    self.timeout = timeout
  }

  var timeoutMilliseconds: UInt32 {
    let (seconds, attoseconds) = timeout.components
    return UInt32(clamping: max(0, seconds * 1_000 + attoseconds / 1_000_000_000_000_000))
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
