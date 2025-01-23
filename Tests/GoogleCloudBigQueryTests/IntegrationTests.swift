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
            let list: [Object]
        }

        struct Object: Decodable, Equatable {
            let property: String
        }

        let result = try await bigQuery.query(
            "SELECT \"Hello, World!\" AS message, 1 AS int, [STRUCT('value' AS property)] AS list",
            as: Row.self
        )
        #expect(result.rows.count == 1)
        #expect(result.totalRows == 1)
        #expect(result.affectedRows == 0)

        let row = try #require(result.rows.first)
        #expect(row.message == "Hello, World!")
        #expect(row.int == 1)
        #expect(row.list == [Object(property: "value")])
    }

    @Test func shouldQueryAndReturnRowsWithParameters() async throws {

        struct Row: Decodable {

            let message: String
            let int: Int
            let bool: Bool
            let someRecord: SomeRecord
            let someArray: [Double]
            let date: Date
        }

        struct SomeRecord: Codable {

            let key: String
            let value: Int
        }

        let result = try await bigQuery.query(
            "SELECT \("Hello, World!") AS message, \(1) AS int, \(true) AS bool, \(SomeRecord(key: "someKey", value: 123)) AS someRecord, \([1.1, 1.2]) AS someArray, \(Date(timeIntervalSince1970: 1_737_610_102)) AS date",
            as: Row.self
        )
        #expect(result.rows.count == 1)
        #expect(result.totalRows == 1)
        #expect(result.affectedRows == 0)

        let row = try #require(result.rows.first)
        #expect(row.message == "Hello, World!")
        #expect(row.int == 1)
        #expect(row.bool == true)
        #expect(row.someRecord.key == "someKey")
        #expect(row.someRecord.value == 123)
        #expect(row.someArray == [1.1, 1.2])
        #expect(row.date == Date(timeIntervalSince1970: 1_737_610_102))
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
