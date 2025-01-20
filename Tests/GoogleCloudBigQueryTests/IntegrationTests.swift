import Foundation
import GoogleCloudServiceContext
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

    @Test func shouldQueryAndReturnRows() async throws {

        struct Row: Decodable {

            let message: String
            let int: Int
        }

        let result = try await bigQuery.query(
            "SELECT \"Hello, World!\" AS message, 1 AS int",
            as: Row.self
        )
        #expect(result.rows.count == 1)
        #expect(result.totalRows == 1)
        #expect(result.affectedRows == 0)

        let row = try #require(result.rows.first)
        #expect(row.message == "Hello, World!")
        #expect(row.int == 1)
    }

    @Test func shouldQueryAndReturnRowsWithParameters() async throws {

        struct Row: Decodable {

            let message: String
            let int: Int
            let bool: Bool
        }

        let result = try await bigQuery.query(
            "SELECT \("Hello, World!") AS message, \(1) AS int, \(true) AS bool",
            as: Row.self
        )
        #expect(result.rows.count == 1)
        #expect(result.totalRows == 1)
        #expect(result.affectedRows == 0)

        let row = try #require(result.rows.first)
        #expect(row.message == "Hello, World!")
        #expect(row.int == 1)
        #expect(row.bool == true)
    }

    @Test func shouldQueryInsert() async throws {
        let projectID = try #require(await ServiceContext.topLevel.projectID)

        let result = try await bigQuery.query(
            """
            INSERT INTO `\(unsafe: projectID).my_dataset.my_table`
            (
                a_string,
                a_int,
                a_timestamp
            )
            VALUES
            (
                "Hello, world!",
                1,
                CURRENT_TIMESTAMP()
            )
            """
        )
        #expect(result.affectedRows == 1)
    }
}
