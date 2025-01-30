import Foundation
import Testing

@testable import GoogleCloudBigQuery

@Suite struct DecoderTests {

  @Test func shouldDecodeAllTypes() throws {

    struct Row: Decodable {

      let nullString: String?
      let string: String
      let double: Double
      let int: Int
      let float: Float
      let bool: Bool
      let object: Object
      let list: [String]
      let date: Date

      struct Object: Decodable {

        let property: String
      }
    }

    let row = try RowDecoder().decode(
      Row.self,
      from: .with {
        $0.fields = [
          "f": .with {
            $0.listValue = [
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with {
                        $0.kind = .nullValue(.nullValue)
                      }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with {
                        $0.kind = .stringValue("text")
                      }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with {
                        $0.kind = .numberValue(1.13)
                      }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .numberValue(2) }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .numberValue(3) }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .boolValue(true) }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with {
                        $0.kind = .structValue(
                          .with {
                            $0.fields = [
                              "property": .with {
                                $0.kind = .stringValue("value")
                              }
                            ]
                          })
                      }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with {
                        $0.kind = .listValue(
                          .with { $0.values = ["something"] })
                      }
                    ]
                  }
                )
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with {
                        $0.kind = .stringValue(
                          "2025-02-01 12:45:30.123456 UTC"
                        )
                      }
                    ]
                  })
              },
            ]
          }
        ]
      },
      schema: .with {
        $0.fields = [
          .with { $0.name = "nullString" },
          .with { $0.name = "string" },
          .with { $0.name = "double" },
          .with { $0.name = "int" },
          .with { $0.name = "float" },
          .with { $0.name = "bool" },
          .with { $0.name = "object" },
          .with { $0.name = "list" },
          .with { $0.name = "date" },
        ]
      }
    )

    #expect(row.nullString == nil)
    #expect(row.string == "text")
    #expect(row.double == 1.13)
    #expect(row.int == 2)
    #expect(row.float == 3)
    #expect(row.bool == true)
    #expect(row.object.property == "value")
    #expect(row.list == ["something"])
    #expect(row.date.timeIntervalSince1970 == 1738413930.123)
  }

  // TODO: Add more tests
}
