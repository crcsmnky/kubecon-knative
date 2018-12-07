#!/bin/bash

set -e

CLUSTER_NAME=knative-demo
CLUSTER_ZONE=us-west1-c

function error_exit
{
    echo "$1" 1>&2
    exit 1
}

echo "# Creating cluster ${CLUSTER_NAME}"
gcloud container clusters create $CLUSTER_NAME \
--zone $CLUSTER_ZONE \
--cluster-version=latest \
--machine-type=n1-standard-4 \
--enable-autoscaling --min-nodes=1 --max-nodes=10 \
--enable-autorepair \
--scopes=service-control,service-management,compute-rw,storage-ro,cloud-platform,logging-write,monitoring-write,pubsub,datastore \
--num-nodes=5

echo "# Creating cluster-admin role binding for $(gcloud config get-value core/account)"
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole=cluster-admin \
--user=$(gcloud config get-value core/account)

echo "# Installing Istio on cluster ${CLUSTER_NAME}"
kubectl apply -f https://raw.githubusercontent.com/knative/serving/master/third_party/istio-1.0.2/istio.yaml

echo "# Enabling istio-injection on default namespace"
kubectl label namespace default istio-injection=enabled

echo "# Sleeping for 60s to await Istio setup"
sleep 60

echo "# Starting Istio Pod watcher, hit ctrl-c to stop"
kubectl get pods -n istio-system --watch

