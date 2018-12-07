#!/bin/bash

set -e

function error_exit
{
    echo "$1" 1>&2
    exit 1
}

echo "# Installing Knative 0.2.2"
kubectl apply -f https://github.com/knative/serving/releases/download/v0.2.2/release.yaml

echo "# Starting Knative Pod watcher, hit ctrl-c to stop"
kubectl get pods -n knative-serving --watch
