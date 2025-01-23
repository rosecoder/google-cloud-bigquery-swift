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

    // Unwrap each value from common field "v" recursively
    values = try values.enumerated().map { index, value in
      try unwrapValue(value, schema: schema.fields[index])
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

  private func unwrapValue(
    _ value: Google_Protobuf_Value,
    schema: Google_Cloud_Bigquery_V2_TableFieldSchema
  ) throws -> Google_Protobuf_Value {
    guard let unwrapped = value.structValue.fields["v"] else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: "Missing field value"
        )
      )
    }

    // Recursively unwrap nested structures
    switch unwrapped.kind {
    case .structValue(let structValue):
      if let nestedList = structValue.fields["f"]?.listValue {
        let unwrappedValues = try nestedList.values.enumerated().map { index, value in
          try unwrapValue(value, schema: schema.fields[index])
        }
        var result = Google_Protobuf_Value()
        var resultStruct = Google_Protobuf_Struct()
        let fields = Dictionary(
          uniqueKeysWithValues: zip(
            schema.fields.map { $0.name },
            unwrappedValues
          )
        )
        resultStruct.fields = fields
        result.structValue = resultStruct
        return result
      }
      return unwrapped
    case .listValue(let list):
      var result = Google_Protobuf_Value()
      result.listValue.values = try list.values.map { value in
        if case .structValue = value.kind {
          return try unwrapValue(value, schema: schema)
        } else {
          return value
        }
      }
      return result
    default:
      return unwrapped
    }
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
          userInfo: userInfo,
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
