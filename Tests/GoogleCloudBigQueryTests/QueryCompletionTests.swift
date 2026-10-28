import NIOCore
import SwiftProtobuf
import Testing

@testable import GoogleCloudBigQuery

@Suite struct QueryCompletionTests {

  private actor Polls {
    var jobReferences: [Google_Cloud_Bigquery_V2_JobReference] = []

    func record(_ jobReference: Google_Cloud_Bigquery_V2_JobReference) -> Int {
      jobReferences.append(jobReference)
      return jobReferences.count
    }
  }

  private static let jobReference = Google_Cloud_Bigquery_V2_JobReference.with {
    $0.projectID = "project"
    $0.jobID = "job"
    $0.location = .with { $0.value = "EU" }
  }

  private static func response(
    complete: Bool,
    jobReference: Google_Cloud_Bigquery_V2_JobReference? = jobReference,
    totalRows: UInt64? = nil
  ) -> Google_Cloud_Bigquery_V2_QueryResponse {
    .with {
      $0.jobComplete = .with { $0.value = complete }
      if let jobReference {
        $0.jobReference = jobReference
      }
      if let totalRows {
        $0.totalRows = .with { $0.value = totalRows }
      }
    }
  }

  @Test func shouldReturnCompletedResponseWithoutPolling() async throws {
    let polls = Polls()

    let response = try await BigQuery.waitForCompletion(
      of: Self.response(complete: true, totalRows: 1)
    ) { jobReference in
      _ = await polls.record(jobReference)
      return Self.response(complete: true)
    }

    #expect(response.totalRows.value == 1)
    #expect(await polls.jobReferences.isEmpty)
  }

  @Test func shouldPollUntilJobCompletes() async throws {
    let polls = Polls()

    let response = try await BigQuery.waitForCompletion(
      of: Self.response(complete: false)
    ) { jobReference in
      let count = await polls.record(jobReference)
      return Self.response(complete: count == 3, totalRows: count == 3 ? 42 : nil)
    }

    #expect(response.jobComplete.value)
    #expect(response.totalRows.value == 42)
    #expect(await polls.jobReferences == Array(repeating: Self.jobReference, count: 3))
  }

  @Test func shouldKeepPollingOriginalJobReference() async throws {
    let polls = Polls()

    _ = try await BigQuery.waitForCompletion(
      of: Self.response(complete: false)
    ) { jobReference in
      let count = await polls.record(jobReference)
      return Self.response(complete: count == 2, jobReference: nil)
    }

    #expect(await polls.jobReferences == [Self.jobReference, Self.jobReference])
  }

  @Test func shouldThrowWhenIncompleteWithoutJobReference() async throws {
    await #expect(throws: BigQuery.QueryError.self) {
      try await BigQuery.waitForCompletion(
        of: Self.response(complete: false, jobReference: nil)
      ) { _ in
        Self.response(complete: true)
      }
    }
  }

  @Test func shouldRethrowPollErrors() async throws {
    struct PollError: Error {}

    await #expect(throws: PollError.self) {
      try await BigQuery.waitForCompletion(
        of: Self.response(complete: false)
      ) { _ in
        throw PollError()
      }
    }
  }

  @Test func shouldStopPollingWhenCancelled() async throws {
    let task = Task {
      try await BigQuery.waitForCompletion(
        of: Self.response(complete: false)
      ) { _ in
        try await Task.sleep(for: .milliseconds(10))
        return Self.response(complete: false)
      }
    }
    task.cancel()

    await #expect(throws: CancellationError.self) {
      try await task.value
    }
  }

  @Test func shouldParseJobReferenceOfAlreadyExistsMessage() throws {
    let jobReference = try #require(
      BigQuery.jobReference(
        fromAlreadyExistsMessage: "Already Exists: Job my-project:EU.job_FmBIu2KWSHk67e7-MmIej9g"
      )
    )
    #expect(jobReference.projectID == "my-project")
    #expect(jobReference.location.value == "EU")
    #expect(jobReference.jobID == "job_FmBIu2KWSHk67e7-MmIej9g")
  }

  @Test func shouldParseJobReferenceOfDomainScopedProject() throws {
    let jobReference = try #require(
      BigQuery.jobReference(
        fromAlreadyExistsMessage: "Already Exists: Job example.com:my-project:europe-west3.job_abc"
      )
    )
    #expect(jobReference.projectID == "example.com:my-project")
    #expect(jobReference.location.value == "europe-west3")
    #expect(jobReference.jobID == "job_abc")
  }

  @Test(arguments: [
    "Already Exists: Table my-project:my_dataset.my_table",
    "Already Exists: Job my-project.job_abc",
    "Already Exists: Job :EU.job_abc",
    "Already Exists: Job my-project:EU.",
    "Already Exists: Job my-project:EU.job abc",
    "Something else",
  ])
  func shouldNotParseJobReferenceOfOtherMessages(message: String) {
    #expect(BigQuery.jobReference(fromAlreadyExistsMessage: message) == nil)
  }

  @Test func shouldDefaultTimeoutToTenSeconds() {
    let literal: Query = "SELECT 1"
    let interpolated: Query = "SELECT \(1)"
    #expect(literal.timeout == .seconds(10))
    #expect(interpolated.timeout == .seconds(10))
    #expect(Query(sql: "SELECT 1").timeout == .seconds(10))
    #expect(Query(unsafeSQL: "SELECT 1").timeout == .seconds(10))
    #expect(literal.timeoutMilliseconds == 10_000)
  }

  @Test func shouldConvertTimeoutToMilliseconds() {
    #expect(Query(sql: "SELECT 1", timeout: .seconds(90)).timeoutMilliseconds == 90_000)
    #expect(Query(sql: "SELECT 1", timeout: .milliseconds(1_500)).timeoutMilliseconds == 1_500)
    #expect(Query(sql: "SELECT 1", timeout: .seconds(-1)).timeoutMilliseconds == 0)
  }

  @Test func shouldAllowHTTPRequestToOutliveQueryTimeout() {
    #expect(BigQuery.httpTimeout(forQueryTimeoutMilliseconds: 10_000) == .seconds(40))
    #expect(BigQuery.httpTimeout(forQueryTimeoutMilliseconds: 200_000) == .seconds(230))
  }
}
