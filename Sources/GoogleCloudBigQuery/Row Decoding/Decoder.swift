import SwiftProtobuf

struct RowDecoder {

  func decode<Row: Decodable>(
    _ type: Row.Type,
    from raw: Google_Protobuf_Struct,
    schema: Google_Cloud_Bigquery_V2_TableSchema
  ) throws -> Row {

    // Unwrap fields from common field "f"
    guard var values = raw.fields["f"]?.listValue.values else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: "Missing fields"
        )
      )
    }

    // Unwrap each value from common field "v"
    values = try values.map {
      guard let value = $0.structValue.fields["v"] else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: [],
            debugDescription: "Missing field value"
          )
        )
      }
      return value
    }

    // TODO: Performance: Skip this step so we don't store field names in memory duplicated so many times
    // Map to dictionary with field names
    let fields = Dictionary(
      uniqueKeysWithValues: zip(
        schema.fields.map(\.name),
        values.prefix(schema.fields.count)
      )
    )

    return try Row.init(from: _Decoder(raw: fields))
  }

  private struct _Decoder: Swift.Decoder {

    var codingPath: [CodingKey] { [] }
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    let raw: [String: Google_Protobuf_Value]

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
    where Key: CodingKey {
      KeyedDecodingContainer(
        KeyedContainer<Key>(
          codingPath: codingPath,
          fields: raw
        ))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      fatalError("Root entity must be decoded as keyed container")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
      fatalError("Root entity must be decoded as keyed container")
    }
  }

  struct UndecodableTypeError: Error {

    let codingPath: [CodingKey]
    let expectedKind: Google_Protobuf_Value.OneOf_Kind?
  }
}
