# Helm chart for Promyze

This Helm chart will run the [Hub Promyze](https://hub.docker.com/r/promyze/hub) on a self-hosted version.

## Usage

[Helm](https://helm.sh) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, you're ready to go.

1. ### Add the repository and run the commands

```bash
helm repo add promyze https://promyze.github.io/helm-charts
helm repo update
helm search repo promyze
```

You should have a result similar to this (versions might be outdated in the following example)
``` 
NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
promyze/hub-promyze     1               1               Hub Promyze - Public ...
promyze/promyze         0.2.0           4.11.1          Raise your own best c...  
```

2. ### First basic run


Install the chart:

```bash
helm upgrade -f values.yaml --install hub-promyze promyze/hub-promyze --create-namespace --namespace promyze
```

Access it:

```bash
kubectl port-forward service/app 3001:80 -n promyze-hub
``` 

And the Hub should be available on ```<Cluster_IP>:80```


## MongoDB 4.x connection

Before installing the chart, you can check the default **values** [here](https://github.com/promyze/helm-charts/blob/main/charts/hub/values.yaml), especially about the **MongoDB 4.x** connection.


You have 2 options to deal with MongoDB.

### 1. Use the embedded MongoDB 4.x (default mode)

Setting the `app.databaseEmbedded.enabled` at `true` will run a MongoDB instance in the cluster.

```
app:
  ...
  databaseEmbedded:
    enabled: true # use an internal mongodb in the cluster
```

The `app.databaseEmbedded.enabled` at `true` will run a MongoDB instance in the cluster.

There is a section `app.databaseEmbedded.pvc` to deal with the persistent storage, enabled by default.

### 2. Use your instance MongoDB 4.x

Setting the `app.databaseEmbedded.enabled` at `false` will require you to indicate the URI of your MongoDB instance.

See the `app.databaseUri` section to set the URI.

```
app:
 ...
 databaseUri:
    value: "mongodb://mongodb:27017/promyze" # You can set the direct URI
    # secret: # Or pass it as a secret
    #   name: mongodb-secret
    #   key: mongodb-uri
```


### Real scenario with cert-manager, Let's Encrypt & NGINX Ingress Controller

```bash
# retrieves public IP
NGINX_PUBLIC_IP=`kubectl get service -n ingress-nginx ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`

# applies the manifest (add "--debug > output.yaml" in case of issue)
helm upgrade --install hub-promyze . -f values.yaml --create-namespace \
  --set ingress.tls.enabled=true,ingress.tls.secrets.app=promyze-tls \
  --set ingress.hostnames.app=hub-promyze.${NGINX_PUBLIC_IP}.sslip.io \
  --namespace promyze
```


## Other settings

Environment variables for the Docker image are described on the [Documentation](https://hub.docker.com/r/promyze/hub).

## Remove the chart

To uninstall the chart and clean-up the cluster:

```bash
helm delete hub-promyze
kubectl delete ns promyze
```

