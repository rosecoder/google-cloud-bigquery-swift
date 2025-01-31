# Google Cloud BigQuery for Swift

A Swift implementation for interacting with Google Cloud BigQuery, designed as a server-first solution.

The vision of this package is to provide a high-level, but still performant, way to interact with BigQuery from Swift. This using Swift-native features like `Codable` and strict concurrency.

## Features

- Querying – using type safe string interpolation.
- Batch writing – using [Storage Write API](https://cloud.google.com/bigquery/docs/write-api).

Yes, that's it. It's a early work in progress package. Feel free to contrinubte with either creating an issue or a pull request.

## Usage

### Querying

```swift
struct Row: Decodable {

    let someField: String
}

try await withBigQuery { bigQuery in
    let result = try await bigQuery.query(
        "SELECT someField FROM `my_dataset.my_table`",
        as: Row.self
    )
    // result.rows contains rows returned from BigQuery
}
```

String interpolation to paramaterize queries is also supported. For example:

```swift
struct SomeRecord: Encodable {

    let key: String
    let value: Int
}

let tableName = "my_table"
let id = "123"
let record = SomeRecord(key: "someKey", value: 123)
let array = [true, false]
let query: Query = """
    INSERT INTO `my_dataset.\(unsafe: tableName)` ( -- Must use unsafe-argument to skip paramatirization
        id,
        someRecordField,
        someArrayField
    ) VALUES (
        \(id), -- This will encode as type STRING
        \(someRecordField), -- This will encode as type STRUCT<key: STRING, value: INT64>
        \(array) -- This will encode as type ARRAY<BOOL>
    )
"""

try await bigQuery.query(query)
```

### Batch writing

The batch writing is a powerful feature that allows you to write many rows in a single stream. The stream handles retries and in-order delivery in a safe way. The data is commited first after all rows have been sent to BigQuery.

```swift
struct Row: Encodable {

    let id: Int
    let name: String
}

try await bigQuery.batchWrite(datasetID: "my_dataset", tableID: "my_table") { stream in
    try await stream.write(rows: [
        Row(id: 1, name: "John"),
        Row(id: 2, name: "Jane"),
    ])
}
```

## Development

### Running tests

There's some integration tests which requires setting up a service account. Setup a `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to a service account JSON file before running `swift test`. If not is not set, the integration tests will be skipped. The service account needs to be able to execute jobs and have access to a dataset and table named `my_dataset.my_table`.

## License

MIT License. See [LICENSE](./LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
