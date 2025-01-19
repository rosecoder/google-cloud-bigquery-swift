// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: google/cloud/bigquery/v2/range_partitioning.proto
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

package struct Google_Cloud_Bigquery_V2_RangePartitioning: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Required. The name of the column to partition the table on. It must be a
  /// top-level, INT64 column whose mode is NULLABLE or REQUIRED.
  package var field: String = String()

  /// Defines the ranges for range partitioning.
  package var range: Google_Cloud_Bigquery_V2_RangePartitioning.Range {
    get {return _range ?? Google_Cloud_Bigquery_V2_RangePartitioning.Range()}
    set {_range = newValue}
  }
  /// Returns true if `range` has been explicitly set.
  package var hasRange: Bool {return self._range != nil}
  /// Clears the value of `range`. Subsequent reads from it will return its default value.
  package mutating func clearRange() {self._range = nil}

  package var unknownFields = SwiftProtobuf.UnknownStorage()

  /// Defines the ranges for range partitioning.
  package struct Range: Sendable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Required. The start of range partitioning, inclusive. This field is an
    /// INT64 value represented as a string.
    package var start: String = String()

    /// Required. The end of range partitioning, exclusive. This field is an
    /// INT64 value represented as a string.
    package var end: String = String()

    /// Required. The width of each interval. This field is an INT64 value
    /// represented as a string.
    package var interval: String = String()

    package var unknownFields = SwiftProtobuf.UnknownStorage()

    package init() {}
  }

  package init() {}

  fileprivate var _range: Google_Cloud_Bigquery_V2_RangePartitioning.Range? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "google.cloud.bigquery.v2"

extension Google_Cloud_Bigquery_V2_RangePartitioning: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  package static let protoMessageName: String = _protobuf_package + ".RangePartitioning"
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "field"),
    2: .same(proto: "range"),
  ]

  package mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.field) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._range) }()
      default: break
      }
    }
  }

  package func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.field.isEmpty {
      try visitor.visitSingularStringField(value: self.field, fieldNumber: 1)
    }
    try { if let v = self._range {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  package static func ==(lhs: Google_Cloud_Bigquery_V2_RangePartitioning, rhs: Google_Cloud_Bigquery_V2_RangePartitioning) -> Bool {
    if lhs.field != rhs.field {return false}
    if lhs._range != rhs._range {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Google_Cloud_Bigquery_V2_RangePartitioning.Range: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  package static let protoMessageName: String = Google_Cloud_Bigquery_V2_RangePartitioning.protoMessageName + ".Range"
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "start"),
    2: .same(proto: "end"),
    3: .same(proto: "interval"),
  ]

  package mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.start) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.end) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.interval) }()
      default: break
      }
    }
  }

  package func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.start.isEmpty {
      try visitor.visitSingularStringField(value: self.start, fieldNumber: 1)
    }
    if !self.end.isEmpty {
      try visitor.visitSingularStringField(value: self.end, fieldNumber: 2)
    }
    if !self.interval.isEmpty {
      try visitor.visitSingularStringField(value: self.interval, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  package static func ==(lhs: Google_Cloud_Bigquery_V2_RangePartitioning.Range, rhs: Google_Cloud_Bigquery_V2_RangePartitioning.Range) -> Bool {
    if lhs.start != rhs.start {return false}
    if lhs.end != rhs.end {return false}
    if lhs.interval != rhs.interval {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
