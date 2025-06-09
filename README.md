This repository contains code for a microservice demo project using [go](https://go.dev/doc/) and [postgres](https://www.postgresql.org/).
The entire process is documented and compiled into a paper using [typst](https://typst.app/).

# How to run in Minikube

1. Install the CloudNativePG Operator

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

2. Build Docker Images
```bash
eval $(minikube docker-env)
docker buildx bake
```

3. Install the acd-microservice-go Helm Chart
```bash
helm upgrade --install acd-microservice-go .
```
