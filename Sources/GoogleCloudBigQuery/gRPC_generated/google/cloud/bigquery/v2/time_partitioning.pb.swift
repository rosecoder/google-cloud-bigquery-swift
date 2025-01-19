// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: google/cloud/bigquery/v2/time_partitioning.proto
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

package struct Google_Cloud_Bigquery_V2_TimePartitioning: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Required. The supported types are DAY, HOUR, MONTH, and YEAR, which will
  /// generate one partition per day, hour, month, and year, respectively.
  package var type: String = String()

  /// Optional. Number of milliseconds for which to keep the storage for a
  /// partition.
  /// A wrapper is used here because 0 is an invalid value.
  package var expirationMs: SwiftProtobuf.Google_Protobuf_Int64Value {
    get {return _expirationMs ?? SwiftProtobuf.Google_Protobuf_Int64Value()}
    set {_expirationMs = newValue}
  }
  /// Returns true if `expirationMs` has been explicitly set.
  package var hasExpirationMs: Bool {return self._expirationMs != nil}
  /// Clears the value of `expirationMs`. Subsequent reads from it will return its default value.
  package mutating func clearExpirationMs() {self._expirationMs = nil}

  /// Optional. If not set, the table is partitioned by pseudo
  /// column '_PARTITIONTIME'; if set, the table is partitioned by this field.
  /// The field must be a top-level TIMESTAMP or DATE field. Its mode must be
  /// NULLABLE or REQUIRED.
  /// A wrapper is used here because an empty string is an invalid value.
  package var field: SwiftProtobuf.Google_Protobuf_StringValue {
    get {return _field ?? SwiftProtobuf.Google_Protobuf_StringValue()}
    set {_field = newValue}
  }
  /// Returns true if `field` has been explicitly set.
  package var hasField: Bool {return self._field != nil}
  /// Clears the value of `field`. Subsequent reads from it will return its default value.
  package mutating func clearField() {self._field = nil}

  package var unknownFields = SwiftProtobuf.UnknownStorage()

  package init() {}

  fileprivate var _expirationMs: SwiftProtobuf.Google_Protobuf_Int64Value? = nil
  fileprivate var _field: SwiftProtobuf.Google_Protobuf_StringValue? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "google.cloud.bigquery.v2"

extension Google_Cloud_Bigquery_V2_TimePartitioning: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  package static let protoMessageName: String = _protobuf_package + ".TimePartitioning"
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .standard(proto: "expiration_ms"),
    3: .same(proto: "field"),
  ]

  package mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.type) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._expirationMs) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._field) }()
      default: break
      }
    }
  }

  package func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.type.isEmpty {
      try visitor.visitSingularStringField(value: self.type, fieldNumber: 1)
    }
    try { if let v = self._expirationMs {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._field {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  package static func ==(lhs: Google_Cloud_Bigquery_V2_TimePartitioning, rhs: Google_Cloud_Bigquery_V2_TimePartitioning) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs._expirationMs != rhs._expirationMs {return false}
    if lhs._field != rhs._field {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
