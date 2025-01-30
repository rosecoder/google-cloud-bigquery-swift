public typealias QueryCodable = QueryEncodable & QueryDecodable

public protocol QueryDecodable: Decodable {}

public protocol QueryEncodable: Encodable {

  static var bigQueryType: BigQueryType { get }
}

extension Array: QueryEncodable where Element: QueryEncodable {

  public static var bigQueryType: BigQueryType {
    .array(Element.bigQueryType)
  }
}

extension Optional: QueryEncodable where Wrapped: QueryEncodable {

  public static var bigQueryType: BigQueryType {
    Wrapped.bigQueryType
  }
}
