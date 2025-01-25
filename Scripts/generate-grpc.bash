SOURCES_ROOT="$(pwd)/Sources"

rm -rf ${SOURCES_ROOT}/*/gRPC_generated/*

cd googleapis/

echo "Generating gRPC code for BigQuery..."
protoc google/cloud/bigquery/v2/*.proto google/cloud/bigquery/storage/v1/*.proto google/type/expr.proto google/rpc/status.proto \
  --swift_opt=Visibility=Package \
  --swift_out=${SOURCES_ROOT}/GoogleCloudBigQuery/gRPC_generated/ \
  --grpc-swift_opt=Client=true,Server=false \
  --grpc-swift_opt=Visibility=Package \
  --grpc-swift_out=${SOURCES_ROOT}/GoogleCloudBigQuery/gRPC_generated/

# Fix conflict of same name from BigQuery v2 API and BigQuery Storage API
mv "${SOURCES_ROOT}/GoogleCloudBigQuery/gRPC_generated/google/cloud/bigquery/storage/v1/table.pb.swift" \
  "${SOURCES_ROOT}/GoogleCloudBigQuery/gRPC_generated/google/cloud/bigquery/storage/v1/table-storage.pb.swift"
