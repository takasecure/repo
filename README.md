# takasecure Helm Charts Repository

This repository contains Helm charts for deploying takasecure services on Kubernetes.

---

## Prerequisites

- [Helm](https://helm.sh/) installed
- Access to a Kubernetes cluster (local or cloud)
- `kubectl` configured for your cluster

---

## Available Charts

- `taka-auth`
- `taka-backup`
- `taka-crypto`
- `taka-dispatch`
- `taka-masking`

---

## Helm Chart Documentation

For detailed information on how to install and configure the Helm charts, please see the [Helm Chart Documentation](./src/README.md).

---

## Add the Helm Repository

    helm repo add takasecure https://takasecure.github.io/repo/charts
    helm repo update

---

## List Available Charts

    helm search repo takasecure

---

## Install a Chart

Replace `<chart-name>`, `<release-name>`, and `<version>` as needed.

    helm install <release-name> takasecure/<chart-name> --version <version>

Example:

    helm install my-auth-service takasecure/taka-auth --version 1.0.0

---

## Upgrade a Release

    helm upgrade <release-name> takasecure/<chart-name> --version <version>

---

## Uninstall a Release

    helm uninstall <release-name>

---

## Customizing Values

You can override chart defaults using a custom `values.yaml` file:

    helm install <release-name> takasecure/<chart-name> -f my-values.yaml

---

## run.sh

The `run.sh` script is a utility for installing, uninstalling, and upgrading the takasecure services.

### Usage

```bash
curl -sSL https://raw.githubusercontent.com/takasecure/repo/refs/heads/master/run.sh | bash -s -- [install|uninstall|upgrade]
```

### Commands

* `install`: Installs the application and all dependencies.
* `uninstall`: Removes the application and all its components.
* `upgrade`: Upgrades the application to the latest version.

### Technical Documentation

The `run.sh` script performs the following actions:

* **Checks for root privileges**: The script must be run as root.
* **Checks the Debian version**: The script requires Debian 10 (Buster) or newer.
* **Installs Docker and Docker Compose**: The script installs Docker and Docker Compose if they are not already installed.
* **Gets user credentials**: The script prompts the user for the following credentials:
    * NATS username and password
    * Domain name for the website
    * Web tag specific version
    * NATS cluster IP addresses
    * NATS consumer name
    * SMTP host, port, username, and password
    * JWT secret
* **Saves configuration files**: The script saves the following configuration files in the `/opt/takasecure` directory:
    * `auth-service.env`
    * `crypto-service.env`
    * `gateway-service.env`
    * `website-service.env`
    * `nats.conf`
    * `dispatch.env`
    * `lock-service.env`
    * `masking-service.env`
    * `tokenize-service.env`
    * `file-service.env`
    * `backup-service.env`
* **Creates a Docker Compose file**: The script creates a `docker-compose.yml` file in the `/opt/takasecure` directory.
* **Starts the services**: The script starts the services using `docker-compose up -d`.

---

## Troubleshooting

- Ensure `kubectl` is connected to the correct cluster:
  kubectl cluster-info
- Update Helm repo if charts are missing:
  helm repo update
- Preview manifests before installing:
  helm template takasecure/<chart-name> -f my-values.yaml

---

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [takasecure Helm Repository](https://takasecure.github.io/repo/charts)
