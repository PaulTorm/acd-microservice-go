SERVICE_NAME = service1

LOCATION ?= default-location
PROJECT_ID ?= project-id
SHORT_SHA ?= latest

REGISTRY = ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE_NAME}

.PHONY: build test containerize push

build:
	@echo "Building ${SERVICE_NAME}"
	go install
	go build -o bin/${SERVICE_NAME}

test:
	@echo "Testing ${SERVICE_NAME}"
	go test ./... -cover

containerize:
	@echo "Containerize ${SERVICE_NAME}"
	cd ../.. && docker build \
		-t ${REGISTRY}/${SERVICE_NAME}:${SHORT_SHA} \
		-t ${REGISTRY}/${SERVICE_NAME}:latest \
		-t ${SERVICE_NAME}:${SHORT_SHA} \
		-t ${SERVICE_NAME}:latest \
		-f ./services/${SERVICE_NAME}/Dockerfile .
