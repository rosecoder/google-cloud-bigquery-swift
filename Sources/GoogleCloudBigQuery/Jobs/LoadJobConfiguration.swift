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

    public init(
        sourceFormat: SourceFormat = .csv,
        writeDisposition: WriteDisposition = .append,
        createDisposition: CreateDisposition = .ifNeeded,
        autodetect: Bool = false
    ) {
        self.sourceFormat = sourceFormat
        self.writeDisposition = writeDisposition
        self.createDisposition = createDisposition
        self.autodetect = autodetect
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
