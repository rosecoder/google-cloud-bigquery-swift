import Testing

@testable import GoogleCloudBigQuery

@Suite struct QueryTests {

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

    @Test func shouldInitializeFromInterpolationWithTypeBool() throws {
        let query: Query = "SELECT \(true)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first?.type == "BOOL")
        #expect(query.parameters.first?.value == "TRUE")
    }
}
