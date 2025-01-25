#if canImport(Foundation)
    import Foundation
#endif

extension BigQueryType {

    init?<Element: Encodable>(anySwiftType type: Element.Type) {
        if type == Int.self
            || type == Int8.self
            || type == Int16.self
            || type == Int32.self
            || type == Int64.self
            || type == UInt.self
            || type == UInt8.self
            || type == UInt16.self
            || type == UInt32.self
            || type == UInt64.self
        {
            self = .int64
            return
        }
        if type == Float.self || type == Double.self {
            self = .float64
            return
        }
        if type == String.self {
            self = .string
            return
        }
        if type == Bool.self {
            self = .bool
            return
        }
        #if canImport(Foundation)
            if type == Date.self {
                self = .timestamp
                return
            }
        #endif
        if type == [Int].self
            || type == [Int8].self
            || type == [Int16].self
            || type == [Int32].self
            || type == [Int64].self
            || type == [UInt].self
            || type == [UInt8].self
            || type == [UInt16].self
            || type == [UInt32].self
            || type == [UInt64].self
        {
            self = .array(.int64)
            return
        }
        if type == [Float].self || type == [Double].self {
            self = .array(.float64)
            return
        }
        if type == [String].self {
            self = .array(.string)
            return
        }
        if type == [Bool].self {
            self = .array(.bool)
            return
        }
        #if canImport(Foundation)
            if type == [Date].self {
                self = .array(.timestamp)
                return
            }
        #endif
        return nil
    }
}
