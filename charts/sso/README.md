# Deploy Cryptr for using Single Sign-On with Packmind

[Cryptr](https://www.cryptr.co/) is a service that provides Single Sign-On (SSO) for applications.
This chart deploys Cryptr for use with Packmind.

Important note: this is not the official documentation for deploying Cryptr with Kubernetes. This is a version suggested by Packmind.

## Principles

* This Cryptr version is intended to be deployed in your own infrastructure and does not require external network connection. This is relevant if, for instance, your Auth Provider is not accessible from the internet.
* In case you host Packmind but are fine with using Cryptr's cloud service, it is possible. Check our [documentation](https://docs.packmind.io/docs/sso/cryptr) on that topic.
* You will deploy Cryptr in your Kubernetes cluster, and it will be accessible from a specific endpoint, such as `https://sso-packmind.acme.com`. This endpoint will be used by Packmind to authenticate users.
* Both `Packmind` and `Cryptr` are deployed separately, as they are two separate app with different life-cycles.

## Components

* `Cryptr`: the SSO service.
* `Vault`: a secret manager used by Cryptr to store sensitive data.
* `TimeScale DB`: a database built on top of `Postgres` and used by Cryptr & Vault to store data.

## Fill the `values.yaml`

Before deploying the chart, you need to fill the `values.yaml` file with the necessary information.

### Add secrets to `vault`

Run the following commands to generate the secrets for `vault`:

```bash
chmod +x gen_vault_secrets.sh
./gen_vault_secrets.sh
```

Two files are generated:
* `env.vault` which contains the environment variables for `vault` and are encoded in base64. They are ready to insert in `values.yaml` in the `vault.env` section.
* `env.vault.k8s.secret`which contains an example of secret file for `vault` in Kubernetes. You can insert it the `templates/secret.yaml` file.

Feel free to use those files with the system to use to manage secrets.

ℹ️ Sometimes the `SECRET_KEY_BASE` outputs a value cut in two lines, in this case, just gather both and make it one line.

## First deployment

Time for your first deployment.
Run a command that looks like this:

```bash
helm upgrade --install sso . -f ./values.yaml -n test-sso --create-namespace
```

ℹ️ **Please note** that, after the first deployment, the `cryptr` service will be in `Failure` mode.
This is because it lacks the necessary configuration to connect to the `vault` service.

This is what we're going to fix now.

Open a shell in the `vault` pod and run the following commands:

```bash
/app> bin/vault eval "Vault.Release.gen_api_key \"sso.acme.com\""
```

Replace `sso.acme.com` with the domain you want to use for the SSO service.

You should see an output like this:

```bash
nobody@vault-6dbd5fc959-d5nxj:/app$ bin/vault eval "Vault.Release.gen_api_key \"https://sso.acme.com\""
14:17:35.251 [info] Configuration :server was not enabled for VaultWeb.Endpoint, http/https services won't start
14:17:35.973 [info] VAULT_CLIENT_ID=392a85ac-1005-47a7-bcbd-a25a71b6d2ab
14:17:35.973 [info] VAULT_CLIENT_SECRET=4c3-L4ug3s5vF4h_7u6Qj2h9F7YsA6bWb1o2g9QkMOSnu_Yp2K4DgeeQb97qQK7sIS5Aep2gzmUcFmFVhq3FVkl1w5YCjD7lysdF6WMy7fconLWAo6POwrUJOh4UiNP9
```

Then retrieve both `VAULT_CLIENT_ID` and `VAULT_CLIENT_SECRET`, you'll have to use them as environment variables of the `cryptr` service.

## Add secrets to `cryptr`

Same manipulation with `cryptr`, you need to run the following commands to generate the secrets for `vault`:

```bash
chmod +x gen_cryptr_secrets.sh
./gen_cryptr_secrets.sh
```

Includes them in the `cryptr.env` or `cryptr.secrets` section of the `values.yaml`.

ℹ️ Both values `DIRECTORY_SYNC_PEPPER` and `SECRET_KEY_BASE` may be truncated on two lines, make sure they are on one line.

Then, go through the rest of the environment variables and fill them.

⚠️ You can include the `VAULT_CLIENT_ID` and `VAULT_CLIENT_SECRET` generated above.

Last point is the `LICENSE_KEY` value. You'll have to contact Packmind to get it, we'll send it back to you then.

## Second deployment

Re-deploy the helm chart to apply the changes.

Now the `cryptr` should be updated and running.

You should then open a shell inside the pod `cryptr` and run the following commands:
```bash
/app> bin/cleeck_umbrella remote
/app> Cleeck.Accounts.create(%{name: "Promyze", members: [%{email: "cedric.teyton@promyze.com"}]})
/app> Cleeck.Accounts.toggle_refresh_tokens(Cleeck.Accounts.get!("promyze"))
```

## Access the dashboard

Now access the value specified in your Ingress, which should be something like https://dashboard.sso.acme.com.

Use then the login and password you've set up in `` and ``.
