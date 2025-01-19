import Foundation
import Testing

@testable import GoogleCloudBigQuery

@Suite(
    .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["GOOGLE_APPLICATION_CREDENTIALS"] != nil)
)
final class IntegrationTests {

    let bigQuery: BigQuery
    let runTask: Task<Void, Error>

    init() async throws {
        let bigQuery = try await BigQuery()
        self.bigQuery = bigQuery
        self.runTask = Task {
            try await bigQuery.run()
        }
    }

    deinit {
        runTask.cancel()
    }
}
