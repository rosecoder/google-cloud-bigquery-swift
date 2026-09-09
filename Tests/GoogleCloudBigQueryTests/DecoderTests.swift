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

  @Test func shouldDecodeJSON() throws {

    struct Row: Decodable {

      let object: Object
      let dictionary: [String: String]
      let list: [Int]
      let number: Int
      let text: String
      let bool: Bool
      let null: String?

      struct Object: Decodable, Equatable {

        let property: String
        let nested: Nested

        struct Nested: Decodable, Equatable {

          let deep: Bool
        }
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
                        $0.kind = .stringValue(
                          "{\"property\":\"value\",\"nested\":{\"deep\":true}}"
                        )
                      }
                    ]
                  })
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .stringValue("{\"key\":\"value\"}") }
                    ]
                  })
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .stringValue("[1,2,3]") }
                    ]
                  })
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .stringValue("42") }
                    ]
                  })
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .stringValue("\"text\"") }
                    ]
                  })
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .stringValue("true") }
                    ]
                  })
              },
              .with {
                $0.kind = .structValue(
                  .with {
                    $0.fields = [
                      "v": .with { $0.kind = .stringValue("null") }
                    ]
                  })
              },
            ]
          }
        ]
      },
      schema: .with {
        $0.fields = [
          .with {
            $0.name = "object"
            $0.type = "JSON"
          },
          .with {
            $0.name = "dictionary"
            $0.type = "JSON"
          },
          .with {
            $0.name = "list"
            $0.type = "JSON"
          },
          .with {
            $0.name = "number"
            $0.type = "JSON"
          },
          .with {
            $0.name = "text"
            $0.type = "JSON"
          },
          .with {
            $0.name = "bool"
            $0.type = "JSON"
          },
          .with {
            $0.name = "null"
            $0.type = "JSON"
          },
        ]
      }
    )

    #expect(
      row.object
        == Row.Object(property: "value", nested: Row.Object.Nested(deep: true))
    )
    #expect(row.dictionary == ["key": "value"])
    #expect(row.list == [1, 2, 3])
    #expect(row.number == 42)
    #expect(row.text == "text")
    #expect(row.bool == true)
    #expect(row.null == nil)
  }

  @Test func shouldDecodeJSONNestedInRecord() throws {

    struct Row: Decodable {

      let record: Record

      struct Record: Decodable {

        let payload: Payload

        struct Payload: Decodable, Equatable {

          let property: String
        }
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
                        $0.kind = .structValue(
                          .with {
                            $0.fields = [
                              "f": .with {
                                $0.listValue = [
                                  .with {
                                    $0.kind = .structValue(
                                      .with {
                                        $0.fields = [
                                          "v": .with {
                                            $0.kind = .stringValue(
                                              "{\"property\":\"value\"}")
                                          }
                                        ]
                                      })
                                  }
                                ]
                              }
                            ]
                          })
                      }
                    ]
                  })
              }
            ]
          }
        ]
      },
      schema: .with {
        $0.fields = [
          .with {
            $0.name = "record"
            $0.type = "RECORD"
            $0.fields = [
              .with {
                $0.name = "payload"
                $0.type = "JSON"
              }
            ]
          }
        ]
      }
    )

    #expect(row.record.payload == Row.Record.Payload(property: "value"))
  }

  @Test func shouldDecodeRepeatedJSON() throws {

    struct Row: Decodable {

      let payloads: [Payload]

      struct Payload: Decodable, Equatable {

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
                        $0.listValue = [
                          .with {
                            $0.kind = .structValue(
                              .with {
                                $0.fields = [
                                  "v": .with {
                                    $0.kind = .stringValue("{\"property\":\"a\"}")
                                  }
                                ]
                              })
                          },
                          .with {
                            $0.kind = .structValue(
                              .with {
                                $0.fields = [
                                  "v": .with {
                                    $0.kind = .stringValue("{\"property\":\"b\"}")
                                  }
                                ]
                              })
                          },
                        ]
                      }
                    ]
                  })
              }
            ]
          }
        ]
      },
      schema: .with {
        $0.fields = [
          .with {
            $0.name = "payloads"
            $0.type = "JSON"
            $0.mode = "REPEATED"
          }
        ]
      }
    )

    #expect(
      row.payloads == [
        Row.Payload(property: "a"),
        Row.Payload(property: "b"),
      ])
  }

  @Test func shouldThrowWhenDecodingInvalidJSON() throws {

    struct Row: Decodable {

      let payload: [String: String]
    }

    #expect(throws: DecodingError.self) {
      try RowDecoder().decode(
        Row.self,
        from: .with {
          $0.fields = [
            "f": .with {
              $0.listValue = [
                .with {
                  $0.kind = .structValue(
                    .with {
                      $0.fields = [
                        "v": .with { $0.kind = .stringValue("{not json") }
                      ]
                    })
                }
              ]
            }
          ]
        },
        schema: .with {
          $0.fields = [
            .with {
              $0.name = "payload"
              $0.type = "JSON"
            }
          ]
        }
      )
    }
  }

  // TODO: Add more tests
}
