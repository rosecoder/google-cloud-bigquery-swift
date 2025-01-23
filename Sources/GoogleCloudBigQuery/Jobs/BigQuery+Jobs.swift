import RetryableTask
import Tracing

extension BigQuery {

  public enum QueryError: Error {
    /// Job was not completed within the given timeout.
    case jobNotYetComplete
  }

  /// Executes a query against BigQuery and returns the results.
  ///
  /// - Parameters:
  ///   - query: The SQL query to execute
  ///   - type: The type to decode the results into. Must conform to `Decodable`.
  ///   - location: The geographic location where the job should run. For more information: https://cloud.google.com/bigquery/docs/locations#specify_locations
  /// - Returns: A `QueryResult` containing the decoded rows.
  public func query<Row: Decodable>(
    _ query: Query,
    as type: Row.Type = Row.self,
    location: String?,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
  ) async throws -> QueryResult<Row> {
    try await self.query(
      query,
      location: location,
      map: { response in
        let decoder = RowDecoder()
        let rows: [Row] = try response.rows.map {
          try decoder.decode(Row.self, from: $0, schema: response.schema)
        }
        return QueryResult(
          rows: rows,
          totalRows: response.totalRows.value,
          affectedRows: response.numDmlAffectedRows.value
        )
      },
      file: file,
      function: function,
      line: line
    )
  }

  /// Executes a query against BigQuery and returns the results. Location to run is inferred from the application.
  ///
  /// - Parameters:
  ///   - query: The SQL query to execute
  ///   - type: The type to decode the results into. Must conform to `Decodable`.
  /// - Returns: A `QueryResult` containing the decoded rows.
  public func query<Row: Decodable>(
    _ query: Query,
    as type: Row.Type = Row.self,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
  ) async throws -> QueryResult<Row> {
    let serviceContext = ServiceContext.current ?? .topLevel
    return try await self.query(
      query,
      as: type,
      location: await serviceContext.locationID,
      file: file,
      function: function,
      line: line
    )
  }

  /// Executes a query against BigQuery and returns the results.
  ///
  /// - Parameters:
  ///   - query: The SQL query to execute
  ///   - location: The geographic location where the job should run. For more information: https://cloud.google.com/bigquery/docs/locations#specify_locations
  /// - Returns: A `QueryResultMeta` containing the metadata.
  @discardableResult public func query(
    _ query: Query,
    location: String?,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
  ) async throws -> QueryResultMeta {
    try await self.query(
      query,
      location: location,
      map: {
        QueryResultMeta(
          totalRows: $0.totalRows.value,
          affectedRows: $0.numDmlAffectedRows.value
        )
      },
      file: file,
      function: function,
      line: line
    )
  }

  /// Executes a query against BigQuery and returns the results. Location to run is inferred from the application.
  ///
  /// - Parameters:
  ///   - query: The SQL query to execute
  /// - Returns: A `QueryResultMeta` containing the metadata.
  @discardableResult public func query(
    _ query: Query,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
  ) async throws -> QueryResultMeta {
    try await self.query(
      query,
      location: nil,
      file: file,
      function: function,
      line: line
    )
  }

  private func query<Result>(
    _ query: Query,
    location: String?,
    map: (Google_Cloud_Bigquery_V2_QueryResponse) throws -> Result,
    file: String,
    function: String,
    line: UInt
  ) async throws -> Result {
    try await withSpan("bigquery-query", ofKind: .client) { span in
      span.attributes["bigquery/query"] = query.sql

      // Execute query
      let response: Google_Cloud_Bigquery_V2_QueryResponse = try await withRetryableTask(
        logger: logger,
        operation: {
          try await request(
            method: .POST, path: "/queries",
            body: Google_Cloud_Bigquery_V2_QueryRequest.with {
              $0.query = query.sql
              if !query.parameters.isEmpty {
                $0.parameterMode = "POSITIONAL"
                $0.queryParameters = query.parameters.map(encode)
              }
              if let maxResults = query.maxResults {
                $0.maxResults = .with {
                  $0.value = maxResults
                }
              }
              $0.useLegacySql = false
              $0.jobCreationMode = .jobCreationOptional
              if let location {
                $0.location = location
              }
            })
        }, file: file, function: function, line: line)

      span.addEvent("received")

      // Check if done
      guard response.jobComplete.value else {
        throw QueryError.jobNotYetComplete  // TODO: Maybe we should wait for it to finish?
      }
      return try map(response)
    }
  }

  private func encode(parameter: Query.Parameter) -> Google_Cloud_Bigquery_V2_QueryParameter {
    return .with {
      $0.parameterType = encode(parameterType: parameter.value)
      $0.parameterValue = encode(parameterValue: parameter.value)
    }
  }

  private func encode(parameterValue value: Query.Parameter.Value)
    -> Google_Cloud_Bigquery_V2_QueryParameterValue
  {
    switch value {
    case .flat(let value, _):
      return .with {
        $0.value = .with {
          $0.value = value
        }
      }
    case .array(let values, _):
      return .with {
        $0.arrayValues = values.map(encode)
      }
    case .struct(let values):
      return .with {
        $0.structValues = values.mapValues(encode)
      }
    }
  }

  private func encode(parameterType value: Query.Parameter.Value)
    -> Google_Cloud_Bigquery_V2_QueryParameterType
  {
    switch value {
    case .flat(_, let type):
      return .with {
        $0.type = type
      }
    case .array(_, let elementType):
      return .with {
        $0.type = "ARRAY"
        $0.arrayType = encode(parameterType: elementType)
      }
    case .struct(let values):
      return .with {
        $0.type = "STRUCT"
        $0.structTypes = values.map { key, value in
          .with {
            $0.name = key
            $0.type = encode(parameterType: value)
          }
        }
      }
    }
  }
}
