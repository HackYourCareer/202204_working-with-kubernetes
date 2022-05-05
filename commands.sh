# Cleanup
docker rm $(docker ps -a -q) -f
docker rmi $(docker images -a -q) -f

# Simple app
vim app.go 
open "http://localhost:8080" 
go run app.go

# Back to the slides

# Dockerfile
cat Dockerfile
docker build -t ghcr.io/ralikio/images/app:latest .
docker run -d -p 8080:8080 --name server ghcr.io/ralikio/images/app:latest

# See inside
docker ps
open "http://localhost:8080" 
docker top server
docker images ghcr.io/ralikio/images/app:latest --format "{{.Repository}}:{{.Tag}}\t{{.Size}}"
docker history ghcr.io/ralikio/images/app:latest

# Modify builds
vimdiff Dockerfile Dockerfile.scratch
docker build -t ghcr.io/ralikio/images/app:latest . -f Dockerfile.scratch
docker images ghcr.io/ralikio/images/app:latest --format "{{.Repository}}:{{.Tag}}\t{{.Size}}"
docker history ghcr.io/ralikio/images/app:latest

# Pushing
docker login ghcr.io -u ralikio
docker push ghcr.io/ralikio/images/app:latest
open "https://github.com/users/ralikio/packages/container/package/images%2Fapp" # Change to private

# Stopping the container
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Cluster creation
k3d cluster create --agents 1 dev -p "8082:30080@loadbalancer"
k3d cluster list
docker ps

# Kubeconfig
k3d kubeconfig get -a
export KUBECONFIG="$(k3d kubeconfig write dev)"

kubectl config view
kubectl config use-context k3d-dev
kubectl config set-context --current --namespace=default

# Running payloads
kubectl run debug --image=radial/busyboxplus:curl -i --tty -- sh
kubectl run app --image=ghcr.io/ralikio/images/app:latest
kubectl logs -f app
kubectl port-forward app 8080
open "http://localhost:8080/"

# Pod Abstraction
kubectl get pods
kubectl get pod app -o yaml

# Cleanup
kubectl delete pod app
ubectl delete pod debug

# Debugging
vimdiff Dockerfile.scratch Dockerfile.debug
docker build -t ghcr.io/ralikio/images/debug:latest -f Dockerfile.debug .
docker push ghcr.io/ralikio/images/debug:latest
kubectl run debug --image=ghcr.io/ralikio/images/debug:latest
kubectl get pods
kubectl logs -f debug
kubectl port-forward debug 40000 8080
# go tool compile -help

# Back to the slides

# Workloads
kubectl delete pod debug
cat deployment.yaml
kubectl apply -f deployment.yaml 
kubectl get deployments -o wide
kubectl get pod
kubectl delete pod app
kubectl get pod

kubectl apply -f service.yaml
kubectl get svc  
open "http://localhost:8082"

# Helm Example
# helm create helm-chart 
helm install nginx ./helm-chart

