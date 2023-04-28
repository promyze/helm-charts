# Helm chart for Promyze

This Helm chart will the Hub Promyze: https://hub.docker.com/r/promyze/hub
## Usage

[Helm](https://helm.sh) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repository:

```bash
helm repo add promyze https://promyze.github.io/helm-charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages. You can then run `helm search repo promyze` to see the charts.

Before installing the chart, you can check the default **values** [here](https://github.com/promyze/helm-charts/blob/main/charts/hub/values.yaml), especially about the **MongoDB 4.x** connection.

## MongoDB 4.x connection

You have 2 options to deal with MongoDB.

### 1. Use the embedded MongoDB 4.x

Setting the `app.databaseEmbedded.enabled` at `true` will run a MongoDB instance in the cluster.

```
app:
  ...
  databaseEmbedded:
    enabled: true # use an internal mongodb in the cluster
```

The `app.databaseEmbedded.enabled` at `true` will run a MongoDB instance in the cluster.

There is a section `app.databaseEmbedded.pvc` to deal with the persistent storage, disabled by default.

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

## Run the chart

To install the chart:

```bash
helm upgrade --install promyze-hub promyze/promyze-hub --create-namespace --namespace promyze
```

To uninstall the chart and clean-up the cluster:

```bash
helm delete promyze
kubectl delete ns promyze
```
