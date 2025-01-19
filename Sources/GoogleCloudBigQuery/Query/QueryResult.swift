public protocol QueryResultProtocol {

  /// The total number of rows in the result set.
  var totalRows: UInt64 { get }

  /// The number of rows affected (inserted, updated, and/or deleted) by the query.
  var affectedRows: Int64 { get }
}

/// The result of a query against BigQuery, with decoded rows.
public struct QueryResult<Row: Decodable>: QueryResultProtocol {

  /// The rows returned by the query.
  public let rows: [Row]

  /// The total number of rows in the result set.
  public let totalRows: UInt64

  /// The number of rows affected (inserted, updated, and/or deleted) by the query.
  public let affectedRows: Int64
}

/// The result of a query against BigQuery, without any rows.
public struct QueryResultMeta: QueryResultProtocol {

  /// The total number of rows in the result set.
  public let totalRows: UInt64

  /// The number of rows affected (inserted, updated, and/or deleted) by the query.
  public let affectedRows: Int64
}
