// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: google/cloud/bigquery/v2/external_catalog_dataset_options.proto
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

/// Options defining open source compatible datasets living in the BigQuery
/// catalog. Contains metadata of open source database, schema
/// or namespace represented by the current dataset.
package struct Google_Cloud_Bigquery_V2_ExternalCatalogDatasetOptions: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Optional. A map of key value pairs defining the parameters and properties
  /// of the open source schema. Maximum size of 2Mib.
  package var parameters: Dictionary<String,String> = [:]

  /// Optional. The storage location URI for all tables in the dataset.
  /// Equivalent to hive metastore's database locationUri. Maximum length of 1024
  /// characters.
  package var defaultStorageLocationUri: String = String()

  package var unknownFields = SwiftProtobuf.UnknownStorage()

  package init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "google.cloud.bigquery.v2"

extension Google_Cloud_Bigquery_V2_ExternalCatalogDatasetOptions: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  package static let protoMessageName: String = _protobuf_package + ".ExternalCatalogDatasetOptions"
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "parameters"),
    2: .standard(proto: "default_storage_location_uri"),
  ]

  package mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString,SwiftProtobuf.ProtobufString>.self, value: &self.parameters) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.defaultStorageLocationUri) }()
      default: break
      }
    }
  }

  package func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.parameters.isEmpty {
      try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString,SwiftProtobuf.ProtobufString>.self, value: self.parameters, fieldNumber: 1)
    }
    if !self.defaultStorageLocationUri.isEmpty {
      try visitor.visitSingularStringField(value: self.defaultStorageLocationUri, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  package static func ==(lhs: Google_Cloud_Bigquery_V2_ExternalCatalogDatasetOptions, rhs: Google_Cloud_Bigquery_V2_ExternalCatalogDatasetOptions) -> Bool {
    if lhs.parameters != rhs.parameters {return false}
    if lhs.defaultStorageLocationUri != rhs.defaultStorageLocationUri {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
