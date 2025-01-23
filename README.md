# Google Cloud BigQuery for Swift

A Swift implementation for interacting with Google Cloud BigQuery, designed as a server-first solution.

## Features

- Querying using type safe string interpolation.

Yes, that's it. It's a early work in progress package.

## Usage

```swift
let bigQuery = try await BigQuery()
Task { bigQuery.run() }

struct Row: Decodable {

    let someField: String
}

let result = try await bigQuery.query("""
    SELECT someField FROM `my_dataset.my_table`
""", as: Row.self)
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

## Development

### Running tests

There's some integration tests which requires setting up a service account. Setup a `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to a service account JSON file before running `swift test`. If not is not set, the integration tests will be skipped. The service account needs to be able to execute jobs and have access to a dataset and table named `my_dataset.my_table`.

## License

MIT License. See [LICENSE](./LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
