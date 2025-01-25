// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: google/rpc/status.proto
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

/// The `Status` type defines a logical error model that is suitable for
/// different programming environments, including REST APIs and RPC APIs. It is
/// used by [gRPC](https://github.com/grpc). Each `Status` message contains
/// three pieces of data: error code, error message, and error details.
///
/// You can find out more about this error model and how to work with it in the
/// [API Design Guide](https://cloud.google.com/apis/design/errors).
package struct Google_Rpc_Status: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The status code, which should be an enum value of
  /// [google.rpc.Code][google.rpc.Code].
  package var code: Int32 = 0

  /// A developer-facing error message, which should be in English. Any
  /// user-facing error message should be localized and sent in the
  /// [google.rpc.Status.details][google.rpc.Status.details] field, or localized
  /// by the client.
  package var message: String = String()

  /// A list of messages that carry the error details.  There is a common set of
  /// message types for APIs to use.
  package var details: [SwiftProtobuf.Google_Protobuf_Any] = []

  package var unknownFields = SwiftProtobuf.UnknownStorage()

  package init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "google.rpc"

extension Google_Rpc_Status: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  package static let protoMessageName: String = _protobuf_package + ".Status"
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "code"),
    2: .same(proto: "message"),
    3: .same(proto: "details"),
  ]

  package mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.code) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.message) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.details) }()
      default: break
      }
    }
  }

  package func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.code != 0 {
      try visitor.visitSingularInt32Field(value: self.code, fieldNumber: 1)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularStringField(value: self.message, fieldNumber: 2)
    }
    if !self.details.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.details, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  package static func ==(lhs: Google_Rpc_Status, rhs: Google_Rpc_Status) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.message != rhs.message {return false}
    if lhs.details != rhs.details {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
