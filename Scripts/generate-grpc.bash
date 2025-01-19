SOURCES_ROOT="$(pwd)/Sources"

rm -rf ${SOURCES_ROOT}/*/gRPC_generated/*

cd googleapis/

echo "Generating gRPC code for BigQuery..."
protoc google/cloud/bigquery/v2/*.proto google/type/expr.proto \
  --swift_opt=Visibility=Package \
  --swift_out=${SOURCES_ROOT}/GoogleCloudBigQuery/gRPC_generated/ \
  --grpc-swift_opt=Client=true,Server=false \
  --grpc-swift_opt=Visibility=Package \
  --grpc-swift_out=${SOURCES_ROOT}/GoogleCloudBigQuery/gRPC_generated/
