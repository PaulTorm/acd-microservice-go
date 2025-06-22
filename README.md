This repository contains code for a microservice demo project using [go](https://go.dev/doc/) and [postgres](https://www.postgresql.org/).
The entire process is documented and compiled into a paper using [typst](https://typst.app/).

# How to run in Minikube

1. Start Minikube
```bash
minikube start --cpus 4 --memory 4096
```

2. Build Docker Images
```bash
eval $(minikube docker-env)
docker buildx bake
```

3. Create TLS Secret
```bash
kubectl create secret tls tls-secret \
  --cert=pos.crt \
  --key=pos.key
```

4. Configure Minikube Ingress Addon
```bash
minikube addons configure ingress
minikube addons enable ingress
```

5. Install the CloudNativePG Operator
```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

6. Install the acd-microservice-go Helm Chart
```bash
helm upgrade --install acd-microservice-go .
```
