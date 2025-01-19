// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: google/cloud/bigquery/v2/system_variable.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// System variables given to a query.
package struct Google_Cloud_Bigquery_V2_SystemVariables: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Output only. Data type for each system variable.
  package var types: Dictionary<String,Google_Cloud_Bigquery_V2_StandardSqlDataType> = [:]

  /// Output only. Value for each system variable.
  package var values: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _values ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_values = newValue}
  }
  /// Returns true if `values` has been explicitly set.
  package var hasValues: Bool {return self._values != nil}
  /// Clears the value of `values`. Subsequent reads from it will return its default value.
  package mutating func clearValues() {self._values = nil}

  package var unknownFields = SwiftProtobuf.UnknownStorage()

  package init() {}

  fileprivate var _values: SwiftProtobuf.Google_Protobuf_Struct? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "google.cloud.bigquery.v2"

extension Google_Cloud_Bigquery_V2_SystemVariables: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  package static let protoMessageName: String = _protobuf_package + ".SystemVariables"
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "types"),
    2: .same(proto: "values"),
  ]

  package mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMessageMap<SwiftProtobuf.ProtobufString,Google_Cloud_Bigquery_V2_StandardSqlDataType>.self, value: &self.types) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._values) }()
      default: break
      }
    }
  }

  package func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.types.isEmpty {
      try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMessageMap<SwiftProtobuf.ProtobufString,Google_Cloud_Bigquery_V2_StandardSqlDataType>.self, value: self.types, fieldNumber: 1)
    }
    try { if let v = self._values {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  package static func ==(lhs: Google_Cloud_Bigquery_V2_SystemVariables, rhs: Google_Cloud_Bigquery_V2_SystemVariables) -> Bool {
    if lhs.types != rhs.types {return false}
    if lhs._values != rhs._values {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
