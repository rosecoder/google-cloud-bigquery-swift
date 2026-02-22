import RetryableTask
import Tracing

extension BigQuery {

  public enum LoadJobError: Error {
    case failed(reason: String, message: String)
  }

  /// Loads data from one or more GCS URIs into a BigQuery table and waits for the job to complete.
  ///
  /// - Parameters:
  ///   - sourceURIs: GCS URIs to load from (e.g. `["gs://my-bucket/data/*.csv"]`).
  ///   - destination: The target dataset and table.
  ///   - configuration: Source format, write disposition, and other load options.
  ///   - location: The geographic location in which to run the job. Defaults to the project default.
  ///   - initialPollInterval: Nanoseconds to wait before the first status poll. Doubles on each
  ///     subsequent poll up to `maxPollInterval`. Defaults to 1 second.
  ///   - maxPollInterval: Maximum nanoseconds to wait between status polls. Defaults to 30 seconds.
  public func loadJob(
    from sourceURIs: [String],
    into destination: LoadDestination,
    configuration: LoadJobConfiguration = LoadJobConfiguration(),
    location: String? = nil,
    initialPollInterval: UInt64 = 1_000_000_000,
    maxPollInterval: UInt64 = 30_000_000_000,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
  ) async throws {
    try await withSpan("bigquery-load-job", ofKind: .client) { span in
      span.attributes["bigquery/destination"] =
        "\(destination.datasetID).\(destination.tableID)"

      // Insert the load job.
      // The REST API for jobs.insert expects a Job resource as the body (project ID is in the URL).
      let job: Google_Cloud_Bigquery_V2_Job = try await withRetryableTask(
        logger: logger,
        operation: {
          try await request(
            method: .POST, path: "/jobs",
            body: Google_Cloud_Bigquery_V2_Job.with {
              $0.configuration = .with {
                $0.load = .with {
                  $0.sourceUris = sourceURIs
                  $0.sourceFormat = configuration.sourceFormat.rawValue
                  $0.writeDisposition = configuration.writeDisposition.rawValue
                  $0.createDisposition = configuration.createDisposition.rawValue
                  $0.autodetect = .with { $0.value = configuration.autodetect }
                  if let schema = configuration.schema {
                    $0.schema = .with {
                      $0.fields = schema.fields.map(Self.protoField)
                    }
                  }
                  $0.destinationTable = .with {
                    $0.projectID = self.projectID
                    $0.datasetID = destination.datasetID
                    $0.tableID = destination.tableID
                  }
                }
              }
              if let location {
                $0.jobReference = .with {
                  $0.location = .with { $0.value = location }
                }
              }
            })
        },
        file: file,
        function: function,
        line: line
      )

      span.addEvent("job-inserted")

      let jobID = job.jobReference.jobID
      let jobLocation =
        job.jobReference.hasLocation
        ? job.jobReference.location.value
        : location

      try await pollJobCompletion(
        jobID: jobID,
        location: jobLocation,
        initialPollInterval: initialPollInterval,
        maxPollInterval: maxPollInterval,
        file: file,
        function: function,
        line: line
      )

      span.addEvent("job-done")
    }
  }

  private func pollJobCompletion(
    jobID: String,
    location: String?,
    initialPollInterval: UInt64,
    maxPollInterval: UInt64,
    file: String,
    function: String,
    line: UInt
  ) async throws {
    var delay = initialPollInterval

    while true {
      try await Task.sleep(nanoseconds: delay)
      delay = min(delay * 2, maxPollInterval)

      var pollPath = "/jobs/\(jobID)"
      if let location {
        pollPath += "?location=\(location)"
      }

      let status: Google_Cloud_Bigquery_V2_Job = try await withRetryableTask(
        logger: logger,
        operation: { try await request(method: .GET, path: pollPath) },
        file: file,
        function: function,
        line: line
      )

      switch status.status.state {
      case "DONE":
        let errorResult = status.status.errorResult
        if !errorResult.reason.isEmpty {
          throw LoadJobError.failed(
            reason: errorResult.reason,
            message: errorResult.message
          )
        }
        return
      default:
        // PENDING or RUNNING — keep polling.
        continue
      }
    }
  }

  private static func protoField(_ field: BigQuerySchema.Field)
    -> Google_Cloud_Bigquery_V2_TableFieldSchema
  {
    .with {
      $0.name = field.name
      $0.type = field.type.rawValue
      $0.mode = field.mode.rawValue
      $0.fields = field.fields.map(protoField)
    }
  }
}
