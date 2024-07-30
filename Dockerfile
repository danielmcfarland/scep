ARG GO_VERSION=1
FROM golang:${GO_VERSION}-bookworm as builder

WORKDIR /usr/src/app
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY . .
RUN go build -v -o /scepserver cmd/scepserver/scepserver.go

FROM debian:bookworm

RUN apt update && apt install -y ca-certificates

WORKDIR /depot

COPY --from=builder /scepserver /usr/local/bin/

ENTRYPOINT scepserver -allowrenew ${ALLOWRENEW:-0} -depot ${DEPOT:-/depot} -challenge ${CHALLENGE:-nanomdm} -debug