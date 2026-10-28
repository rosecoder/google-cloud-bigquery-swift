import NIOCore
import RetryableTask
import Tracing

import struct Foundation.UUID

#if canImport(Foundation)
  import class Foundation.DateFormatter
#endif

extension BigQuery {

  public enum QueryError: Error {
    /// The job didn't complete and BigQuery returned no job reference to wait for.
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

  /// - Parameter requestID: Retries reuse the request ID so BigQuery doesn't run the query twice.
  func query<Result>(
    _ query: Query,
    location: String?,
    requestID: String = UUID().uuidString,
    map: (Google_Cloud_Bigquery_V2_QueryResponse) throws -> Result,
    file: String,
    function: String,
    line: UInt
  ) async throws -> Result {
    try await withSpan("bigquery-query", ofKind: .client) { span in
      span.attributes["bigquery/query"] = query.sql

      let timeoutMilliseconds = query.timeoutMilliseconds

      // Execute query
      let response: Google_Cloud_Bigquery_V2_QueryResponse = try await withRetryableTask(
        logger: logger,
        operation: {
          try await queryRequest(
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
              $0.timeoutMs = .with {
                $0.value = timeoutMilliseconds
              }
              $0.requestID = requestID
              $0.useLegacySql = false
              $0.jobCreationMode = .jobCreationOptional
              if let location {
                $0.location = location
              }
            },
            timeoutMilliseconds: timeoutMilliseconds
          )
        }, file: file, function: function, line: line)

      span.addEvent("received")

      let completedResponse = try await Self.waitForCompletion(of: response) { jobReference in
        span.addEvent("polling")
        return try await queryResults(
          jobReference: jobReference,
          maxResults: query.maxResults,
          timeoutMilliseconds: timeoutMilliseconds,
          file: file,
          function: function,
          line: line
        )
      }
      return try map(completedResponse)
    }
  }

  /// Sends the query. If BigQuery already received a request with the same request ID, it responds
  /// with an error naming the existing job, which is then returned as incomplete to be waited for.
  private func queryRequest(
    body: Google_Cloud_Bigquery_V2_QueryRequest,
    timeoutMilliseconds: UInt32
  ) async throws -> Google_Cloud_Bigquery_V2_QueryResponse {
    do {
      return try await request(
        method: .POST,
        path: "/queries",
        body: body,
        timeout: Self.httpTimeout(forQueryTimeoutMilliseconds: timeoutMilliseconds)
      )
    } catch let error as RemoteError where error.status == "ALREADY_EXISTS" {
      guard let jobReference = Self.jobReference(fromAlreadyExistsMessage: error.message) else {
        throw error
      }
      return .with {
        $0.jobReference = jobReference
        $0.jobComplete = .with { $0.value = false }
      }
    }
  }

  /// Parses messages like `Already Exists: Job my-project:EU.job_abc123`.
  static func jobReference(fromAlreadyExistsMessage message: String)
    -> Google_Cloud_Bigquery_V2_JobReference?
  {
    let prefix = "Already Exists: Job "
    guard message.hasPrefix(prefix) else {
      return nil
    }
    let qualifiedJobID = message.dropFirst(prefix.count)
    guard
      let locationSeparator = qualifiedJobID.lastIndex(of: "."),
      let projectSeparator = qualifiedJobID[..<locationSeparator].lastIndex(of: ":")
    else {
      return nil
    }

    let projectID = qualifiedJobID[..<projectSeparator]
    let location = qualifiedJobID[qualifiedJobID.index(after: projectSeparator)..<locationSeparator]
    let jobID = qualifiedJobID[qualifiedJobID.index(after: locationSeparator)...]
    guard
      !projectID.isEmpty, !location.isEmpty, !jobID.isEmpty,
      jobID.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" })
    else {
      return nil
    }

    return .with {
      $0.projectID = String(projectID)
      $0.jobID = String(jobID)
      $0.location = .with { $0.value = String(location) }
    }
  }

  static func waitForCompletion(
    of response: Google_Cloud_Bigquery_V2_QueryResponse,
    poll: (Google_Cloud_Bigquery_V2_JobReference) async throws ->
      Google_Cloud_Bigquery_V2_QueryResponse
  ) async throws -> Google_Cloud_Bigquery_V2_QueryResponse {
    guard !response.jobComplete.value else {
      return response
    }
    guard response.hasJobReference, !response.jobReference.jobID.isEmpty else {
      throw QueryError.jobNotYetComplete
    }

    let jobReference = response.jobReference
    var response = response
    while !response.jobComplete.value {
      try Task.checkCancellation()
      response = try await poll(jobReference)
    }
    return response
  }

  /// Waits server side for the job to complete for up to `timeoutMilliseconds`, then returns the
  /// first page of results.
  private func queryResults(
    jobReference: Google_Cloud_Bigquery_V2_JobReference,
    maxResults: UInt32?,
    timeoutMilliseconds: UInt32,
    file: String,
    function: String,
    line: UInt
  ) async throws -> Google_Cloud_Bigquery_V2_QueryResponse {
    var path = "/queries/\(jobReference.jobID)?timeoutMs=\(timeoutMilliseconds)"
    if jobReference.hasLocation {
      path += "&location=\(jobReference.location.value)"
    }
    if let maxResults {
      path += "&maxResults=\(maxResults)"
    }

    let results: Google_Cloud_Bigquery_V2_GetQueryResultsResponse = try await withRetryableTask(
      logger: logger,
      operation: {
        try await request(
          method: .GET,
          path: path,
          timeout: Self.httpTimeout(forQueryTimeoutMilliseconds: timeoutMilliseconds)
        )
      }, file: file, function: function, line: line)

    return .with {
      if results.hasSchema {
        $0.schema = results.schema
      }
      $0.jobReference = jobReference
      if results.hasTotalRows {
        $0.totalRows = results.totalRows
      }
      $0.pageToken = results.pageToken
      $0.rows = results.rows
      if results.hasJobComplete {
        $0.jobComplete = results.jobComplete
      }
      if results.hasNumDmlAffectedRows {
        $0.numDmlAffectedRows = results.numDmlAffectedRows
      }
    }
  }

  /// BigQuery may hold a request for up to `timeoutMs` before responding, so the HTTP request must
  /// be allowed to outlive it.
  static func httpTimeout(forQueryTimeoutMilliseconds timeoutMilliseconds: UInt32) -> TimeAmount {
    .milliseconds(Int64(timeoutMilliseconds)) + .seconds(30)
  }

  private func encode(parameter: BigQueryValue) -> Google_Cloud_Bigquery_V2_QueryParameter {
    return .with {
      $0.parameterType = encode(parameterType: parameter.type)
      $0.parameterValue = encode(parameterValue: parameter.storage)
    }
  }

  private func encode(parameterValue value: BigQueryValue.Storage)
    -> Google_Cloud_Bigquery_V2_QueryParameterValue
  {
    switch value {
    case .string(let value):
      return .with {
        if let value {
          $0.value = .with {
            $0.value = value
          }
        }
      }
    case .bool(let value):
      return .with {
        if let value {
          $0.value = .with {
            $0.value = value ? "TRUE" : "FALSE"
          }
        }
      }
    case .int64(let value):
      return .with {
        if let value {
          $0.value = .with {
            $0.value = String(value)
          }
        }
      }
    case .float64(let value):
      return .with {
        if let value {
          $0.value = .with {
            $0.value = String(value)
          }
        }
      }
    #if canImport(Foundation)
      case .timestamp(let value):
        return .with {
          if let value {
            $0.value = .with {
              $0.value = DateFormatter.bigQuery.string(from: value)
            }
          }
        }
    #endif
    case .json(let value):
      return .with {
        if let value {
          $0.value = .with {
            $0.value = value
          }
        }
      }
    case .array(let values):
      return .with {
        $0.arrayValues = values.map { encode(parameterValue: $0.storage) }
      }
    case .struct(let values):
      return .with {
        if let values {
          $0.structValues = Dictionary(
            uniqueKeysWithValues: values.mapValues { encode(parameterValue: $0.storage) }.map {
              key, value in
              (key, value)
            })
        }
      }
    }
  }

  private func encode(parameterType type: BigQueryType)
    -> Google_Cloud_Bigquery_V2_QueryParameterType
  {
    return .with {
      $0.type = type.stringRepresentation
      switch type {
      case .array(let elementType):
        $0.arrayType = encode(parameterType: elementType)
      case .struct(let elementType):
        $0.structTypes = elementType.map { key, value in
          .with {
            $0.name = key
            $0.type = encode(parameterType: value)
          }
        }
      default:
        break
      }
    }
  }
}
