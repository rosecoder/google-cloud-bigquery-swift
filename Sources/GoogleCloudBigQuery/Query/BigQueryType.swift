import OrderedCollections

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
    case `struct`(OrderedDictionary<String, BigQueryType>)

    /// The string representation of the type.
    ///
    /// For example, `STRING` or `ARRAY<STRING>`. See: https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types#data_type_list
    public var stringRepresentation: String {
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

    /// The complete string representation of the type.
    ///
    /// For example, `STRING`, `ARRAY<STRING>` or `STRUCT<a STRING, b INT64>`. See: https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types#data_type_list
    public var completeStringRepresentation: String {
        switch self {
        case .array(let elementType):
            return "ARRAY<\(elementType.completeStringRepresentation)>"
        case .struct(let elementType):
            return
                "STRUCT<\(elementType.map { $0.key + " " + $0.value.completeStringRepresentation } .joined(separator: ", "))>"
        default:
            return stringRepresentation
        }
    }

    var nullValue: BigQueryValue {
        switch self {
        case .string:
            return .init(stringValue: nil, type: .string)
        case .int64:
            return .init(stringValue: nil, type: .int64)
        case .float64:
            return .init(stringValue: nil, type: .float64)
        case .bool:
            return .init(stringValue: nil, type: .bool)
        case .timestamp:
            return .init(stringValue: nil, type: .timestamp)
        case .array(let elementType):
            return .init(value: .array([]), type: .array(elementType))
        case .struct(let elementType):
            return .init(value: .struct(nil), type: .struct(elementType))
        }
    }
}
