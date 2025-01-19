# Google Cloud BigQuery for Swift

A Swift implementation for interacting with Google Cloud BigQuery, designed as a server-first solution.

## Features

- Querying using Swift first APIs.

Yes, that's it. It's a early work in progress package.

## Usage

```swift
let bigQuery = try await BigQuery()
Task { bigQuery.run() }

struct Row {

    let someField: String
}

let result = try await bigQuery.query("""
    SELECT someField FROM `my_dataset.my_table`
""", as: Row.self)
```

## License

MIT License. See [LICENSE](../google-cloud-auth-swift/LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
