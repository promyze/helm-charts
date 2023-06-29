# Contributing guide

All command lines must be ran from "charts/promyze" folder.

## Dependencies

Make sure to run `../../scripts/add_helm_repos.sh`.

Versions can be displayed with `helm search repo -l mongodb --versions`.

When you update `Chart.yaml`, run `helm dependency update` to update `Chart.lock`.

## Generated chart

Run `helm template promyze . -f values.yaml > temp.yaml` to look at what is generated.

## Validation

### Minimalist with MongoDB community operator

```bash
# installs or updates the Helm release
helm upgrade --install promyze-beta . -f values.yaml --create-namespace \
  --set app.databaseUri.value=mongodb://root:admin@promyze-beta-mongodb:27017/promyze?authSource=admin \
  --set mongodb.enabled=true,mongodb.auth.rootPassword=admin \
  --namespace promyze-beta

# (optional) forwards MongoDB port for local access
kubectl port-forward service/promyze-beta-mongodb 27017:27017 -n promyze-beta

# accesses Promyze with http://localhost:3001/
curl http://localhost:3001/

# cleans up
helm delete promyze-beta -n promyze-beta
kubectl delete ns promyze-beta
```

### Real scenario with cert-manager, Let's Encrypt & NGINX Ingress Controller

```bash
# retrieves public IP
NGINX_PUBLIC_IP=`kubectl get service -n ingress-nginx ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`

# applies the manifest (add "--debug > output.yaml" in case of issue)
helm upgrade --install promyze-beta . -f values.yaml --create-namespace \
  --set app.databaseUri.value=mongodb://root:admin@promyze-beta-mongodb:27017/promyze?authSource=admin \
  --set ingress.enabled=true,ingress.className=nginx,ingress.annotations.'cert-manager\.io/cluster-issuer'=letsencrypt-prod \
  --set ingress.tls.enabled=true,ingress.tls.secrets.app=promyze-tls \
  --set ingress.hostnames.app=promyze.${NGINX_PUBLIC_IP}.sslip.io \
  --set mongodb.enabled=true,mongodb.auth.rootPassword=admin \
  --namespace promyze-beta
```
