FROM python:3.5-slim as builder

RUN apt update

RUN pip3 install --upgrade pip && \
    pip3 install grpcio-tools

WORKDIR /opt/src/geometry-client-python
COPY ./ ./

# firgured out the package defintin by looking at comments in this issue https://github.com/google/protobuf/issues/2283
# has to do with having a defined set of package directories for the proto file itself if you're going to publish code to a package itself
RUN python3 -mgrpc_tools.protoc -I=./proto/ --python_out=. ./proto/epl/protobuf/geometry.proto
RUN python3 -mgrpc_tools.protoc -I=./proto/ --python_out=. --grpc_python_out=. ./proto/epl/grpc/geometry_operators.proto


FROM python:3.5-slim

RUN apt update

RUN pip3 install grpcio

# TODO, I thought this wasn't required
RUN pip3 install protobuf
# TODO, I thought this wasn't required

# TODO remove this and place it as an install for the testing
RUN pip3 install shapely

WORKDIR /opt/src/geometry-client-python

COPY --from=builder /opt/src/geometry-client-python /opt/src/geometry-client-python

RUN pip3 install .

ENV GEOMETRY_SERVICE_HOST="localhost:8980"
