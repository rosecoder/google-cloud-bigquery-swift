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

// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the gRPC Swift generator plugin for the protocol buffer compiler.
// Source: google/cloud/bigquery/v2/project.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/grpc/grpc-swift

import GRPCCore
import GRPCProtobuf

// MARK: - google.cloud.bigquery.v2.ProjectService

/// Namespace containing generated types for the "google.cloud.bigquery.v2.ProjectService" service.
package enum Google_Cloud_Bigquery_V2_ProjectService {
    /// Service descriptor for the "google.cloud.bigquery.v2.ProjectService" service.
    package static let descriptor = GRPCCore.ServiceDescriptor(fullyQualifiedService: "google.cloud.bigquery.v2.ProjectService")
    /// Namespace for method metadata.
    package enum Method {
        /// Namespace for "GetServiceAccount" metadata.
        package enum GetServiceAccount {
            /// Request type for "GetServiceAccount".
            package typealias Input = Google_Cloud_Bigquery_V2_GetServiceAccountRequest
            /// Response type for "GetServiceAccount".
            package typealias Output = Google_Cloud_Bigquery_V2_GetServiceAccountResponse
            /// Descriptor for "GetServiceAccount".
            package static let descriptor = GRPCCore.MethodDescriptor(
                service: GRPCCore.ServiceDescriptor(fullyQualifiedService: "google.cloud.bigquery.v2.ProjectService"),
                method: "GetServiceAccount"
            )
        }
        /// Descriptors for all methods in the "google.cloud.bigquery.v2.ProjectService" service.
        package static let descriptors: [GRPCCore.MethodDescriptor] = [
            GetServiceAccount.descriptor
        ]
    }
}

extension GRPCCore.ServiceDescriptor {
    /// Service descriptor for the "google.cloud.bigquery.v2.ProjectService" service.
    package static let google_cloud_bigquery_v2_ProjectService = GRPCCore.ServiceDescriptor(fullyQualifiedService: "google.cloud.bigquery.v2.ProjectService")
}

// MARK: google.cloud.bigquery.v2.ProjectService (client)

extension Google_Cloud_Bigquery_V2_ProjectService {
    /// Generated client protocol for the "google.cloud.bigquery.v2.ProjectService" service.
    ///
    /// You don't need to implement this protocol directly, use the generated
    /// implementation, ``Client``.
    ///
    /// > Source IDL Documentation:
    /// >
    /// > This service provides access to BigQuery functionality related to projects.
    package protocol ClientProtocol: Sendable {
        /// Call the "GetServiceAccount" method.
        ///
        /// > Source IDL Documentation:
        /// >
        /// > RPC to get the service account for a project used for interactions with
        /// > Google Cloud KMS
        ///
        /// - Parameters:
        ///   - request: A request containing a single `Google_Cloud_Bigquery_V2_GetServiceAccountRequest` message.
        ///   - serializer: A serializer for `Google_Cloud_Bigquery_V2_GetServiceAccountRequest` messages.
        ///   - deserializer: A deserializer for `Google_Cloud_Bigquery_V2_GetServiceAccountResponse` messages.
        ///   - options: Options to apply to this RPC.
        ///   - handleResponse: A closure which handles the response, the result of which is
        ///       returned to the caller. Returning from the closure will cancel the RPC if it
        ///       hasn't already finished.
        /// - Returns: The result of `handleResponse`.
        func getServiceAccount<Result>(
            request: GRPCCore.ClientRequest<Google_Cloud_Bigquery_V2_GetServiceAccountRequest>,
            serializer: some GRPCCore.MessageSerializer<Google_Cloud_Bigquery_V2_GetServiceAccountRequest>,
            deserializer: some GRPCCore.MessageDeserializer<Google_Cloud_Bigquery_V2_GetServiceAccountResponse>,
            options: GRPCCore.CallOptions,
            onResponse handleResponse: @Sendable @escaping (GRPCCore.ClientResponse<Google_Cloud_Bigquery_V2_GetServiceAccountResponse>) async throws -> Result
        ) async throws -> Result where Result: Sendable
    }

    /// Generated client for the "google.cloud.bigquery.v2.ProjectService" service.
    ///
    /// The ``Client`` provides an implementation of ``ClientProtocol`` which wraps
    /// a `GRPCCore.GRPCCClient`. The underlying `GRPCClient` provides the long-lived
    /// means of communication with the remote peer.
    ///
    /// > Source IDL Documentation:
    /// >
    /// > This service provides access to BigQuery functionality related to projects.
    package struct Client: ClientProtocol {
        private let client: GRPCCore.GRPCClient

        /// Creates a new client wrapping the provided `GRPCCore.GRPCClient`.
        ///
        /// - Parameters:
        ///   - client: A `GRPCCore.GRPCClient` providing a communication channel to the service.
        package init(wrapping client: GRPCCore.GRPCClient) {
            self.client = client
        }

        /// Call the "GetServiceAccount" method.
        ///
        /// > Source IDL Documentation:
        /// >
        /// > RPC to get the service account for a project used for interactions with
        /// > Google Cloud KMS
        ///
        /// - Parameters:
        ///   - request: A request containing a single `Google_Cloud_Bigquery_V2_GetServiceAccountRequest` message.
        ///   - serializer: A serializer for `Google_Cloud_Bigquery_V2_GetServiceAccountRequest` messages.
        ///   - deserializer: A deserializer for `Google_Cloud_Bigquery_V2_GetServiceAccountResponse` messages.
        ///   - options: Options to apply to this RPC.
        ///   - handleResponse: A closure which handles the response, the result of which is
        ///       returned to the caller. Returning from the closure will cancel the RPC if it
        ///       hasn't already finished.
        /// - Returns: The result of `handleResponse`.
        package func getServiceAccount<Result>(
            request: GRPCCore.ClientRequest<Google_Cloud_Bigquery_V2_GetServiceAccountRequest>,
            serializer: some GRPCCore.MessageSerializer<Google_Cloud_Bigquery_V2_GetServiceAccountRequest>,
            deserializer: some GRPCCore.MessageDeserializer<Google_Cloud_Bigquery_V2_GetServiceAccountResponse>,
            options: GRPCCore.CallOptions = .defaults,
            onResponse handleResponse: @Sendable @escaping (GRPCCore.ClientResponse<Google_Cloud_Bigquery_V2_GetServiceAccountResponse>) async throws -> Result = { response in
                try response.message
            }
        ) async throws -> Result where Result: Sendable {
            try await self.client.unary(
                request: request,
                descriptor: Google_Cloud_Bigquery_V2_ProjectService.Method.GetServiceAccount.descriptor,
                serializer: serializer,
                deserializer: deserializer,
                options: options,
                onResponse: handleResponse
            )
        }
    }
}

// Helpers providing default arguments to 'ClientProtocol' methods.
extension Google_Cloud_Bigquery_V2_ProjectService.ClientProtocol {
    /// Call the "GetServiceAccount" method.
    ///
    /// > Source IDL Documentation:
    /// >
    /// > RPC to get the service account for a project used for interactions with
    /// > Google Cloud KMS
    ///
    /// - Parameters:
    ///   - request: A request containing a single `Google_Cloud_Bigquery_V2_GetServiceAccountRequest` message.
    ///   - options: Options to apply to this RPC.
    ///   - handleResponse: A closure which handles the response, the result of which is
    ///       returned to the caller. Returning from the closure will cancel the RPC if it
    ///       hasn't already finished.
    /// - Returns: The result of `handleResponse`.
    package func getServiceAccount<Result>(
        request: GRPCCore.ClientRequest<Google_Cloud_Bigquery_V2_GetServiceAccountRequest>,
        options: GRPCCore.CallOptions = .defaults,
        onResponse handleResponse: @Sendable @escaping (GRPCCore.ClientResponse<Google_Cloud_Bigquery_V2_GetServiceAccountResponse>) async throws -> Result = { response in
            try response.message
        }
    ) async throws -> Result where Result: Sendable {
        try await self.getServiceAccount(
            request: request,
            serializer: GRPCProtobuf.ProtobufSerializer<Google_Cloud_Bigquery_V2_GetServiceAccountRequest>(),
            deserializer: GRPCProtobuf.ProtobufDeserializer<Google_Cloud_Bigquery_V2_GetServiceAccountResponse>(),
            options: options,
            onResponse: handleResponse
        )
    }
}

// Helpers providing sugared APIs for 'ClientProtocol' methods.
extension Google_Cloud_Bigquery_V2_ProjectService.ClientProtocol {
    /// Call the "GetServiceAccount" method.
    ///
    /// > Source IDL Documentation:
    /// >
    /// > RPC to get the service account for a project used for interactions with
    /// > Google Cloud KMS
    ///
    /// - Parameters:
    ///   - message: request message to send.
    ///   - metadata: Additional metadata to send, defaults to empty.
    ///   - options: Options to apply to this RPC, defaults to `.defaults`.
    ///   - handleResponse: A closure which handles the response, the result of which is
    ///       returned to the caller. Returning from the closure will cancel the RPC if it
    ///       hasn't already finished.
    /// - Returns: The result of `handleResponse`.
    package func getServiceAccount<Result>(
        _ message: Google_Cloud_Bigquery_V2_GetServiceAccountRequest,
        metadata: GRPCCore.Metadata = [:],
        options: GRPCCore.CallOptions = .defaults,
        onResponse handleResponse: @Sendable @escaping (GRPCCore.ClientResponse<Google_Cloud_Bigquery_V2_GetServiceAccountResponse>) async throws -> Result = { response in
            try response.message
        }
    ) async throws -> Result where Result: Sendable {
        let request = GRPCCore.ClientRequest<Google_Cloud_Bigquery_V2_GetServiceAccountRequest>(
            message: message,
            metadata: metadata
        )
        return try await self.getServiceAccount(
            request: request,
            options: options,
            onResponse: handleResponse
        )
    }
}