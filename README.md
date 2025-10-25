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
