FROM golang:1.24 AS build

WORKDIR /acd-microservice-go
COPY . . 
RUN CGO_ENABLED=0 GOOS=linux go build -o bin/service .

FROM scratch
WORKDIR /acd-microservice-go
COPY --from=build /acd-microservice-go/bin/service .
CMD ["./service"]
