public func withBigQuery<Result>(
  projectID: String,
  operation: (BigQuery) async throws -> Result
) async throws -> Result {
  let bigQuery = BigQuery(projectID: projectID)
  let runTask = Task {
    try await bigQuery.run()
  }
  let result = try await operation(bigQuery)
  runTask.cancel()
  try await runTask.value
  return result
}

public func withBigQuery<Result>(
  operation: (BigQuery) async throws -> Result
) async throws -> Result {
  let bigQuery = try await BigQuery()
  let runTask = Task {
    try await bigQuery.run()
  }
  let result = try await operation(bigQuery)
  runTask.cancel()
  try await runTask.value
  return result
}
