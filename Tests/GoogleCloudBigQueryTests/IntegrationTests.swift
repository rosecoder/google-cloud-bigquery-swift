import Foundation
import GoogleCloudAuthTesting
import GoogleCloudBigQuery
import GoogleCloudServiceContext
import Testing

@Suite(.enabledIfAuthenticatedWithGoogleCloud)
struct IntegrationTests {

  @Test func shouldQueryAndReturnRows() async throws {
    try await withBigQuery { bigQuery in
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
  }

  @Test func shouldQueryAndReturnRowsWithParameters() async throws {
    try await withBigQuery { bigQuery in

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
  }

  @Test func shouldQueryAndReturnRowsWithJSON() async throws {
    try await withBigQuery { bigQuery in

      struct Row: Decodable {

        let payload: Payload
        let list: [Int]
      }

      struct Payload: Codable, Equatable {

        let key: String
        let value: Int
      }

      let result = try await bigQuery.query(
        "SELECT \(try BigQueryJSON(Payload(key: "someKey", value: 123))) AS payload, \(BigQueryJSON(text: "[1,2,3]")) AS list",
        as: Row.self
      )
      #expect(result.rows.count == 1)

      let row = try #require(result.rows.first)
      #expect(row.payload == Payload(key: "someKey", value: 123))
      #expect(row.list == [1, 2, 3])
    }
  }

  @Test func shouldQueryInsert() async throws {
    try await withBigQuery { bigQuery in
      let projectID = try #require(await ServiceContext.topLevel.projectID)

      let result = try await bigQuery.query(
        """
        INSERT INTO `\(unsafe: projectID).my_dataset.my_table`
        (
            a_string,
            a_int,
            a_timestamp,
            a_record,
            a_array
        )
        VALUES
        (
            "Hello, world!",
            1,
            CURRENT_TIMESTAMP(),
            STRUCT(
                123 AS a_int
            ),
            ["a", "b"]
        )
        """
      )
      #expect(result.affectedRows == 1)
    }
  }

  @Test func shouldLoadFromGCS() async throws {
    try await withBigQuery { bigQuery in
      try await bigQuery.loadJob(
        from: ["gs://my-bucket/my-file.csv"],
        into: LoadDestination(datasetID: "my_dataset", tableID: "my_table"),
        configuration: LoadJobConfiguration(
          sourceFormat: .csv,
          writeDisposition: .truncate,
          autodetect: true
        )
      )
    }
  }

  @Test func shouldWriteWithStorageWrite() async throws {
    try await withBigQuery { bigQuery in

      struct Row: QueryEncodable {

        static let bigQueryType: BigQueryType = .struct([
          "a_string": .string,
          "a_int": .int64,
          "a_timestamp": .timestamp,
          "a_nullable_string": .string,
          "a_record": .struct([
            "a_int": .int64
          ]),
          "a_array": .array(.string),
          "a_json": .json,
        ])

        let a_string: String
        let a_int: Int
        let a_timestamp: Date
        let a_nullable_string: String?
        let a_record: SomeRecord
        let a_array: [String]
        let a_json: BigQueryJSON

        enum CodingKeys: String, CodingKey {
          case a_string
          case a_int
          case a_timestamp
          case a_nullable_string
          case a_record
          case a_array
          case a_json
        }

        func encode(to encoder: any Swift.Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(a_string, forKey: .a_string)
          try container.encode(a_int, forKey: .a_int)
          try container.encode(a_timestamp, forKey: .a_timestamp)
          try container.encode(a_nullable_string, forKey: .a_nullable_string)
          try container.encode(a_record, forKey: .a_record)
          try container.encode(a_array, forKey: .a_array)
          try container.encode(a_json, forKey: .a_json)
        }
      }

      struct SomeRecord: Codable {

        let a_int: Int
      }

      try await bigQuery.batchWrite(datasetID: "my_dataset", tableID: "my_table") { stream in

        // Insert single row
        try await stream.write(
          row: Row(
            a_string: "This is row 1",
            a_int: 1,
            a_timestamp: Date(),
            a_nullable_string: nil,
            a_record: SomeRecord(a_int: -1),
            a_array: ["a", "b"],
            a_json: BigQueryJSON(text: "{\"row\":1}")
          ))

        // Insert single row again
        try await stream.write(
          row: Row(
            a_string: "This is row 2",
            a_int: 2,
            a_timestamp: Date(),
            a_nullable_string: nil,
            a_record: SomeRecord(a_int: -2),
            a_array: ["c", "d"],
            a_json: BigQueryJSON(text: "{\"row\":2}")
          ))

        // Insert multiple rows
        try await stream.write(rows: [
          Row(
            a_string: "This is row 3",
            a_int: 3,
            a_timestamp: Date(),
            a_nullable_string: nil,
            a_record: SomeRecord(a_int: -3),
            a_array: ["e", "f"],
            a_json: BigQueryJSON(text: "{\"row\":3}")
          ),
          Row(
            a_string: "This is row 4",
            a_int: 4,
            a_timestamp: Date(),
            a_nullable_string: "Still row 4",
            a_record: SomeRecord(a_int: -4),
            a_array: ["g", "h"],
            a_json: try BigQueryJSON(SomeRecord(a_int: -4))
          ),
        ])
      }
    }
  }
}
