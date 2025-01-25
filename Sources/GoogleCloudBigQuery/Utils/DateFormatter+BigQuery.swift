#if canImport(Foundation)
    import Foundation

    extension DateFormatter {

        static let bigQuery: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS 'UTC'"
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter
        }()
    }
#endif
