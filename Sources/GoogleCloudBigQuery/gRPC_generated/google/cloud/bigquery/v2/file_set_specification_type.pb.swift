// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: google/cloud/bigquery/v2/file_set_specification_type.proto
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

/// This enum defines how to interpret source URIs for load jobs and external
/// tables.
package enum Google_Cloud_Bigquery_V2_FileSetSpecType: SwiftProtobuf.Enum, Swift.CaseIterable {
  package typealias RawValue = Int

  /// This option expands source URIs by listing files from the object store. It
  /// is the default behavior if FileSetSpecType is not set.
  case fileSystemMatch // = 0

  /// This option indicates that the provided URIs are newline-delimited manifest
  /// files, with one URI per line. Wildcard URIs are not supported.
  case newLineDelimitedManifest // = 1
  case UNRECOGNIZED(Int)

  package init() {
    self = .fileSystemMatch
  }

  package init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .fileSystemMatch
    case 1: self = .newLineDelimitedManifest
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  package var rawValue: Int {
    switch self {
    case .fileSystemMatch: return 0
    case .newLineDelimitedManifest: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  package static let allCases: [Google_Cloud_Bigquery_V2_FileSetSpecType] = [
    .fileSystemMatch,
    .newLineDelimitedManifest,
  ]

}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension Google_Cloud_Bigquery_V2_FileSetSpecType: SwiftProtobuf._ProtoNameProviding {
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "FILE_SET_SPEC_TYPE_FILE_SYSTEM_MATCH"),
    1: .same(proto: "FILE_SET_SPEC_TYPE_NEW_LINE_DELIMITED_MANIFEST"),
  ]
}
