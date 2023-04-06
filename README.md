# Helm chart for Promyze

[![CI](https://github.com/promyze/helm-charts/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/promyze/helm-charts/actions/workflows/ci.yaml)
[![Release](https://github.com/promyze/helm-charts/actions/workflows/release.yaml/badge.svg?branch=main)](https://github.com/promyze/helm-charts/actions/workflows/release.yaml)

This Helm chart will install [Promyze](https://www.promyze.com/), the collaborative platform dedicated to improve developers’ skills through best practices sharing and definition, on your Kubernetes cluster.

## Usage

[Helm](https://helm.sh) must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repository:

```bash
helm repo add promyze https://promyze.github.io/helm-charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages. You can then run `helm search repo promyze` to see the charts.

To install the chart:

```bash
helm upgrade --install promyze promyze/promyze --create-namespace --namespace promyze
```

To uninstall the chart and clean-up the cluster:

```bash
helm delete promyze
kubectl delete ns promyze
```

## Go further

Look at [Contributing](docs/CONTRIBUTING.md) if you would like to update this repository.
