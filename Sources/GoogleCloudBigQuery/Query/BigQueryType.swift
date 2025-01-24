/// Enum for BigQuery data types.
///
/// Types containing children (like `array` and `struct`) contains their element type, but not in the `stringRepresentation`.
///
/// See: https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types#data_type_list
public indirect enum BigQueryType: Sendable, Equatable {
    case string
    case int64
    case float64
    case bool
    case timestamp
    case array(BigQueryType)
    case `struct`([String: BigQueryType])

    var stringRepresentation: String {
        switch self {
        case .string:
            return "STRING"
        case .int64:
            return "INT64"
        case .float64:
            return "FLOAT64"
        case .bool:
            return "BOOL"
        case .timestamp:
            return "TIMESTAMP"
        case .array:
            return "ARRAY"
        case .struct:
            return "STRUCT"
        }
    }

    var nullValue: Query.Parameter {
        switch self {
        case .string:
            return .init(value: nil, type: .string)
        case .int64:
            return .init(value: nil, type: .int64)
        case .float64:
            return .init(value: nil, type: .float64)
        case .bool:
            return .init(value: nil, type: .bool)
        case .timestamp:
            return .init(value: nil, type: .timestamp)
        case .array(let elementType):
            return .init(value: .array([]), type: .array(elementType))
        case .struct(let elementType):
            return .init(value: .struct(nil), type: .struct(elementType))
        }
    }
}
