import Foundation
import Testing

@testable import GoogleCloudBigQuery

@Suite struct QueryTests {

    @Test func shouldInitializeWithProperties() throws {
        let query = Query(
            sql: "SELECT ?",
            parameters: [.init(value: 1)],
            maxResults: 2
        )
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 1))
        #expect(query.maxResults == 2)
    }

    @Test func shouldInitializeWithPropertiesWithUnsafeSQL() throws {
        let query = Query(
            unsafeSQL: "SELECT" + " ?",
            parameters: [.init(value: 1)],
            maxResults: 2
        )
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 1))
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
        #expect(query.parameters.first == .init(value: 1))
    }

    @Test func shouldInitializeFromMultipleInterpolation() throws {
        let query: Query = "SELECT \(1), \("Test")"
        #expect(query.sql == "SELECT ?, ?")
        #expect(query.parameters.count == 2)
        #expect(query.parameters.first == .init(value: 1))
        #expect(query.parameters.last == .init(value: "Test"))
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
        #expect(query.parameters.first == .init(value: "test"))
    }

    @Test func shouldInitializeFromInterpolationWithTypeStringNil() throws {
        let query: Query = "SELECT \(nil as String?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as String?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt() throws {
        let query: Query = "SELECT \(1)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 1))
    }

    @Test func shouldInitializeFromInterpolationWithTypeIntNil() throws {
        let query: Query = "SELECT \(nil as Int?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Int?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt8() throws {
        let value: Int8 = 8
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 8))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt8Nil() throws {
        let query: Query = "SELECT \(nil as Int8?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Int8?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt16() throws {
        let value: Int16 = 16
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 16))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt16Nil() throws {
        let query: Query = "SELECT \(nil as Int16?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Int16?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt32() throws {
        let value: Int32 = 32
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 32))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt32Nil() throws {
        let query: Query = "SELECT \(nil as Int32?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Int32?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt64() throws {
        let value: Int64 = 64
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 64))
    }

    @Test func shouldInitializeFromInterpolationWithTypeInt64Nil() throws {
        let query: Query = "SELECT \(nil as Int64?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Int64?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt() throws {
        let value: UInt = 1
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 1))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUIntNil() throws {
        let query: Query = "SELECT \(nil as UInt?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as UInt?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt8() throws {
        let value: UInt8 = 8
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 8))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt8Nil() throws {
        let query: Query = "SELECT \(nil as UInt8?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as UInt8?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt16() throws {
        let value: UInt16 = 16
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 16))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt16Nil() throws {
        let query: Query = "SELECT \(nil as UInt16?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as UInt16?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt32() throws {
        let value: UInt32 = 32
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 32))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt32Nil() throws {
        let query: Query = "SELECT \(nil as UInt32?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as UInt32?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt64() throws {
        let value: UInt64 = 64
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 64))
    }

    @Test func shouldInitializeFromInterpolationWithTypeUInt64Nil() throws {
        let query: Query = "SELECT \(nil as UInt64?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as UInt64?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeFloat() throws {
        let value: Float = 3.14
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 3.14))
    }

    @Test func shouldInitializeFromInterpolationWithTypeFloatNil() throws {
        let query: Query = "SELECT \(nil as Float?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Float?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeDouble() throws {
        let value: Double = 3.14159
        let query: Query = "SELECT \(value)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: 3.14159))
    }

    @Test func shouldInitializeFromInterpolationWithTypeDoubleNil() throws {
        let query: Query = "SELECT \(nil as Double?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Double?))
    }

    @Test func shouldInitializeFromInterpolationWithTypeBool() throws {
        let query: Query = "SELECT \(true)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: true))
    }

    @Test func shouldInitializeFromInterpolationWithTypeBoolNil() throws {
        let query: Query = "SELECT \(nil as Bool?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: nil as Bool?))
    }

    @Test func shouldInitializeFromInterpolationWithEncodableAsStruct() throws {

        struct Struct: Encodable {

            let string: String
            let int: Int
            let bool: Bool
        }

        let query: Query = try "SELECT \(Struct(string: "Hello, World!", int: 1, bool: true))"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(
            query.parameters.first
                == .init(
                    value:
                        .struct([
                            "string": .string("Hello, World!"),
                            "int": .string("1"),
                            "bool": .string("TRUE"),
                        ]),
                    type: .struct([
                        "string": .string,
                        "int": .int64,
                        "bool": .bool,
                    ]))
        )
    }

    @Test func shouldInitializeFromInterpolationWithEncodableAsArray() throws {
        let query: Query = try "SELECT \([1, 2, 3])"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(
            query.parameters.first
                == .init(
                    value:
                        .array([
                            .string("1"),
                            .string("2"),
                            .string("3"),
                        ]), type: .array(.int64))
        )
    }

    @Test func shouldInitializeFromInterpolationWithEncodableAsEmptyArray() throws {
        let query: Query = try "SELECT \([] as [Int])"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: .array([]), type: .array(.int64)))
    }

    @Test func shouldInitializeFromInterpolationWithEncodableAsStructWithEmptyArray() throws {

        struct Struct: Encodable {

            let children: [Bool]
        }

        let query: Query = try "SELECT \(Struct(children: []))"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(
            query.parameters.first
                == .init(
                    value: .struct(["children": .array([])]),
                    type: .struct(["children": .array(.bool)])))
    }

    @Test func shouldInitializeFromInterpolationWithEncodableWithManyLevels() throws {

        struct Struct: Encodable {

            let string: String
            let children: [Child]
            let child: Child?

            struct Child: Encodable {

                let prop: Int
            }
        }

        let thing = Struct(
            string: "l1",
            children: [
                Struct.Child(prop: 1),
                Struct.Child(prop: 2),
            ],
            child: Struct.Child(prop: 3)
        )

        let query: Query = try "SELECT \(thing)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(
            query.parameters.first
                == .init(
                    value:
                        .struct([
                            "string": .string("l1"),
                            "children": .array([
                                .struct(["prop": .string("1")]),
                                .struct(["prop": .string("2")]),
                            ]),
                            "child": .struct(["prop": .string("3")]),
                        ]),
                    type: .struct([
                        "string": .string,
                        "children": .array(.struct(["prop": .int64])),
                        "child": .struct(["prop": .int64]),
                    ]))
        )
    }

    @Test func shouldInitializeFromInterpolationWithTypeDate() throws {
        let query: Query = "SELECT \(Date(timeIntervalSince1970: 888_814_502))"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(
            query.parameters.first
                == .init(value: .string("1998-03-02 04:55:02.000000 UTC"), type: .timestamp)
        )
    }

    @Test func shouldInitializeFromInterpolationWithTypeDateNil() throws {
        let query: Query = "SELECT \(nil as Date?)"
        #expect(query.sql == "SELECT ?")
        #expect(query.parameters.count == 1)
        #expect(query.parameters.first == .init(value: .string(nil), type: .timestamp))
    }
}
