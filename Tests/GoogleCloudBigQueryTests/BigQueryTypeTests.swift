import Foundation
import Testing

@testable import GoogleCloudBigQuery

@Suite struct BigQueryTypeTests {

    @Test(arguments: [
        (BigQueryType.string, "STRING"),
        (BigQueryType.int64, "INT64"),
        (BigQueryType.float64, "FLOAT64"),
        (BigQueryType.bool, "BOOL"),
        (BigQueryType.timestamp, "TIMESTAMP"),
        (BigQueryType.array(.string), "ARRAY"),
        (BigQueryType.struct(["a": .string, "b": .int64]), "STRUCT"),
    ])
    func shouldReturnStringRepresentation(type: BigQueryType, expected: String) throws {
        #expect(type.stringRepresentation == expected)
    }

    @Test(arguments: [
        (BigQueryType.string, "STRING"),
        (BigQueryType.int64, "INT64"),
        (BigQueryType.float64, "FLOAT64"),
        (BigQueryType.bool, "BOOL"),
        (BigQueryType.timestamp, "TIMESTAMP"),
    ])
    func shouldReturnCompleteStringRepresentation(type: BigQueryType, expected: String) throws {
        #expect(type.completeStringRepresentation == expected)
    }

    @Test func shouldReturnCompleteStringRepresentationOfArray() throws {
        #expect(BigQueryType.array(.string).completeStringRepresentation == "ARRAY<STRING>")
        #expect(BigQueryType.array(.int64).completeStringRepresentation == "ARRAY<INT64>")
    }

    @Test func shouldReturnCompleteStringRepresentationOfStruct() throws {
        #expect(
            BigQueryType.struct([
                "b": .int64,
                "a": .string,
                "c": .float64,
                "d": .bool,
                "e": .timestamp,
            ]).completeStringRepresentation
                == "STRUCT<b INT64, a STRING, c FLOAT64, d BOOL, e TIMESTAMP>"
        )
    }
}
