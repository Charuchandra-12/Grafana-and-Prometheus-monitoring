#!/bin/bash

# Install Grafana and Prometheus to monitor the CPU, RAM, and storage and make email alerts for 70 percent usage for all monitors.

# using t2.xlarge

# INSTALL Docker
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# Install the Docker packages:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Install minikube cluster (stable release on x86-64 Linux using Debian package)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

# Install kubectl
sudo snap install kubectl --classic

# Start the minukube
sudo usermod -aG docker $USER && newgrp docker

# minikube start --vm-driver=docker
minikube start --cpus 2 --memory 8192 --vm-driver=docker

# Install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update -y
sudo apt-get install helm -y

# INSTALL Prometheus-operator
# add repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update

# Install chart
helm install prometheus prometheus-community/kube-prometheus-stack -f values.yml

# Get Info about the stack
kubectl get all

# Get Info about the configurations for different parts of prometheus, most of them are managed by the operator
kubectl get configmap

# Get Info about the secrets for Grafana, Prometheus, Operator.. which will include username, passcode, and certificates for different parts of the stack
kubectl get secret 

# Access Grafana UI (admin/prom-operator)
kubectl port-forward deployment/prometheus-grafana 3000 --address 0.0.0.0

# Access Prometheus UI (optional)
kubectl port-forward prometheus-prometheus-prometheus-oper-prometheus-0 9090 --address 0.0.0.0

# Get a list of installed charts
helm list -A

# Install stress-ng
sudo apt install stress-ng -y
# stress the system 
stress-ng --cpu 4 --cpu-load 75 --timeout 120s 
stress-ng --vm 1 --vm-bytes 12G --timeout 120s 
stress-ng --hdd 1 --hdd-bytes 18G --timeout 120s 




