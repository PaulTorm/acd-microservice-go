FROM golang:1.24 AS build

WORKDIR /acd-microservice-go

COPY . . 

RUN cd services/service1 && CGO_ENABLED=0 GOOS=linux go build -o bin/ .

FROM scratch

WORKDIR /cmg-ws202425

COPY --from=build /cmg-ws202425/services/worker-registry/bin/service1 .

CMD ["./service1"]
