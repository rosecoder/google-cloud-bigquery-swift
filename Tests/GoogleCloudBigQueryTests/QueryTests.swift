import Testing

@testable import GoogleCloudBigQuery

@Suite struct QueryTests {

    @Test func shouldInitializeWithProperties() throws {
        let query = Query(
            sql: "SELECT ?",
            parameters: [.init(type: "INT64", value: "1")],
            maxResults: 2
        )
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "1")
        #expect(query.maxResults == 2)
    }

    @Test func shouldInitializeWithPropertiesWithUnsafeSQL() throws {
        let query = Query(
            unsafeSQL: "SELECT" + " ?",
            parameters: [.init(type: "INT64", value: "1")],
            maxResults: 2
        )
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "1")
        #expect(query.maxResults == 2)
    }

    @Test func shouldInitializeFromStringLiteral() throws {
        let query: Query = "SELECT 1"
        #expect(query.sql == "SELECT 1")
        #expect(query.parameters.count == 0)
    }

    @Test func shouldInitializeFromSingleInterpolation() throws {
        let query: Query = "SELECT \(1)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "1")
    }

    @Test func shouldInitializeFromMultipleInterpolation() throws {
        let query: Query = "SELECT \(1), \("Test")"
        #expect(query.sql == "SELECT ?, ?")
        #expect(query.parameters.count == 2)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "1")
        #expect(query.parameters.last?.type == "STRING")
        #expect(query.parameters.last?.value == "Test")
    }

    @Test func shouldInitializeFromInterpolationWithStringUnsafe() throws {
        let query: Query = "SELECT \(unsafe: "test")"
        #expect(query.sql == "SELECT test")
        #expect(query.parameters.count == 0)
    }

    @Test func shouldInitializeFromInterpolationWithTypeString() throws {
        let query: Query = "SELECT \("test")"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "STRING")
        #expect(query.parameters.first?.value == "test")
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt() throws {
        let query: Query = "SELECT \(1)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "1")
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt8() throws {
        let value: Int8 = 8
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "8")
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt16() throws {
        let value: Int16 = 16
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "16")
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt32() throws {
        let value: Int32 = 32
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "32")
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt64() throws {
        let value: Int64 = 64
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "64")
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt() throws {
        let value: UInt = 1
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "1")
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt8() throws {
        let value: UInt8 = 8
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "8")
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt16() throws {
        let value: UInt16 = 16
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "16")
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt32() throws {
        let value: UInt32 = 32
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "32")
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt64() throws {
        let value: UInt64 = 64
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "INT64")
        #expect(query.parameters.first?.value == "64")
    }

    @Test func shouldInitializeFromInterpolationWithTypeFloat() throws {
        let value: Float = 3.14
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "FLOAT64")
        #expect(query.parameters.first?.value == "3.14")
    }

    @Test func shouldInitializeFromInterpolationWithTypeDouble() throws {
        let value: Double = 3.14159
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "FLOAT64")
        #expect(query.parameters.first?.value == "3.14159")
    }

    @Test func shouldInitializeFromInterpolationWithTypeBool() throws {
        let query: Query = "SELECT \(true)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "BOOL")
        #expect(query.parameters.first?.value == "TRUE")
    }
}
