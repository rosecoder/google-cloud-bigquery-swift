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
    public func loadJob(
        from sourceURIs: [String],
        into destination: LoadDestination,
        configuration: LoadJobConfiguration = LoadJobConfiguration(),
        location: String? = nil,
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
            let jobLocation = job.jobReference.hasLocation
                ? job.jobReference.location.value
                : location

            // Poll until the job finishes.
            var delay: UInt64 = 1_000_000_000  // 1 second in nanoseconds
            let maxDelay: UInt64 = 30_000_000_000  // 30 seconds

            while true {
                try await Task.sleep(nanoseconds: delay)
                delay = min(delay * 2, maxDelay)

                var pollPath = "/jobs/\(jobID)"
                if let jobLocation {
                    pollPath += "?location=\(jobLocation)"
                }

                let status: Google_Cloud_Bigquery_V2_Job = try await request(
                    method: .GET, path: pollPath)

                switch status.status.state {
                case "DONE":
                    span.addEvent("job-done")
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
    }
}
