# Blue-Green Deployment

*Adapted from [Routing and Managing Traffic with Blue/Green Deployment](https://github.com/knative/docs/blob/master/serving/samples/blue-green-deployment.md)*

## Setup and Context

First run the GKE cluster setup and Knative install, found [here](https://github.com/crcsmnky/kubecon-knative/blob/master/README.md).

Then switch to the `blue-green` directory and set your cluster context for `kubectl`:

```bash
$ cd kubecon-knative/blue-green/
$ kctx gke_kubecon-na-2018_us-west1-c_knative-demo
```

## Deploying Rev 1 (Blue)

The following steps deploy a sample application that displays "App v1" on a blue background.

```bash
$ kubectl apply -f blue-green-config-v1.yaml
$ kubectl apply -f blue-green-route.yaml
```

To view the sample app, grab the external IP:

```bash
$ export IP_ADDRESS=$(kubectl get svc knative-ingressgateway --namespace istio-system --output 'jsonpath={.status.loadBalancer.ingress[0].ip}')
```

Then, grab the full hostname:

```bash
$ export HOST_URL=$(kubectl get ksvc helloworld-go  --output jsonpath='{.status.domain}')
```

Finally, use `curl` to access the deployed app:

```bash
$ curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}
```

## Deploying Rev 2 (Green)

The following steps update the previous deployment with a sample application that display "App v2" on a green background.

```bash
$ kubectl apply -f blue-green-config-v2.yaml
$ kubectl apply -f blue-green-route-100-0.yaml
```

Rev 2 of the sample application is now staged, but traffic is still going to Rev 1. 

Using `curl` you'll see that "App v1" on a blue background is still the default:

```bash
$ curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}
```

To see "App v2" on a green background, use the following:

```bash
$ curl -H "Host: v2.${HOST_URL}" http://${IP_ADDRESS}
```

This approach lets you validate Rev 2 without directing all traffic to it.

## Migrating Traffic from Rev 1 to Rev 2

First, deploy a new route configuration that splits the traffic 50/50 between Rev 1 and Rev 2:

```bash
$ kubectl apply -f blue-green-route-50-50.yaml
```

Use `curl` a few times to see the traffic split:

```bash
$ curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}
```

## Routing All Traffic to Rev 2

Finally, deploy a new route configuration that sends 100% of the traffic to Rev 2:

```bash
$ kubectl apply -f blue-green-route-0-100.yaml
```

Use `curl` a few times to verify that all traffic is going to Rev 2:

```bash
$ curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}
```

With all inbound traffic being directed to the second revision of the application, Knative will soon scale the first revision down to 0 running pods and the blue/green deployment can be considered complete. Using the named `v1` route will reactivate a pod to serve any occassional requests intended specifically for the initial revision.

## Clean Up

```bash
$ kubectl delete route blue-green-demo
$ kubectl delete configuration blue-green-demo
```

