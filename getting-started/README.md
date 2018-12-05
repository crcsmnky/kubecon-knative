# Getting Started

*Adapted from [Getting Started with Knative App Deployment](https://github.com/knative/docs/blob/master/install/getting-started-knative-app.md)*

## Deployment

First, deploy the app:

```bash
$ kubectl apply -f service.yaml
```

Next, grab the external IP:

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

## Cleanup

```bash
$ kubectl delete -f service.yaml
```
