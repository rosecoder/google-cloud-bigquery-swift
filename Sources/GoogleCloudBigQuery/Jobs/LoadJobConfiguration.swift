public struct LoadJobConfiguration: Sendable {
    public enum SourceFormat: Sendable {
        case csv, newlineDelimitedJSON, avro, parquet, orc, datastoreBackup

        var rawValue: String {
            switch self {
            case .csv: return "CSV"
            case .newlineDelimitedJSON: return "NEWLINE_DELIMITED_JSON"
            case .avro: return "AVRO"
            case .parquet: return "PARQUET"
            case .orc: return "ORC"
            case .datastoreBackup: return "DATASTORE_BACKUP"
            }
        }
    }

    public enum WriteDisposition: Sendable {
        case append, truncate, empty

        var rawValue: String {
            switch self {
            case .append: return "WRITE_APPEND"
            case .truncate: return "WRITE_TRUNCATE"
            case .empty: return "WRITE_EMPTY"
            }
        }
    }

    public enum CreateDisposition: Sendable {
        case ifNeeded, never

        var rawValue: String {
            switch self {
            case .ifNeeded: return "CREATE_IF_NEEDED"
            case .never: return "CREATE_NEVER"
            }
        }
    }

    public var sourceFormat: SourceFormat
    public var writeDisposition: WriteDisposition
    public var createDisposition: CreateDisposition
    public var autodetect: Bool
    /// Explicit schema for the destination table. Required when `autodetect` is `false`
    /// and the destination table does not already have a schema.
    public var schema: BigQuerySchema?

    public init(
        sourceFormat: SourceFormat = .csv,
        writeDisposition: WriteDisposition = .append,
        createDisposition: CreateDisposition = .ifNeeded,
        autodetect: Bool = false,
        schema: BigQuerySchema? = nil
    ) {
        self.sourceFormat = sourceFormat
        self.writeDisposition = writeDisposition
        self.createDisposition = createDisposition
        self.autodetect = autodetect
        self.schema = schema
    }
}

// MARK: - Schema types

public struct BigQuerySchema: Sendable {

    public struct Field: Sendable {

        public enum FieldType: String, Sendable {
            case string = "STRING"
            case bytes = "BYTES"
            case integer = "INTEGER"
            case float = "FLOAT"
            case boolean = "BOOLEAN"
            case timestamp = "TIMESTAMP"
            case date = "DATE"
            case time = "TIME"
            case datetime = "DATETIME"
            case geography = "GEOGRAPHY"
            case numeric = "NUMERIC"
            case bignumeric = "BIGNUMERIC"
            case json = "JSON"
            case record = "RECORD"
        }

        public enum Mode: String, Sendable {
            case nullable = "NULLABLE"
            case required = "REQUIRED"
            case repeated = "REPEATED"
        }

        public var name: String
        public var type: FieldType
        public var mode: Mode
        /// Nested fields, only valid when `type` is `.record`.
        public var fields: [Field]

        public init(name: String, type: FieldType, mode: Mode = .nullable, fields: [Field] = []) {
            self.name = name
            self.type = type
            self.mode = mode
            self.fields = fields
        }
    }

    public var fields: [Field]

    public init(fields: [Field]) {
        self.fields = fields
    }
}

public struct LoadDestination: Sendable {
    public var datasetID: String
    public var tableID: String

    public init(datasetID: String, tableID: String) {
        self.datasetID = datasetID
        self.tableID = tableID
    }
}
