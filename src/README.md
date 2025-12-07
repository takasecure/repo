# Helm Charts

This directory contains Helm charts for the following services:

* auth-service
* backup-service
* crypto-service
* dispatch-service
* gateway-service
* masking-service

## Prerequisites

* Kubernetes 1.12+
* Helm 3.0.0+
* PV provisioner support in the underlying infrastructure

## Installing the Charts

To install the charts, you must first add the repository.

### Add the repository

```bash
helm repo add primasys https://primasys.github.io/charts
```

### Install the charts

```bash
helm install my-release primasys/<chart-name>
```

For example, to install the auth-service chart:

```bash
helm install my-release primasys/auth-service
```

## Uninstalling the Charts

To uninstall the `my-release` deployment:

```bash
helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### auth-service

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of replicas to deploy. | `1` |
| `secret.enabled` | Whether to create secrets. | `false` |
| `secret.data` | A list of secrets to create. | `[]` |
| `configMap.enabled` | Whether to create config maps. | `false` |
| `configMap.data` | A list of config maps to create. | `[]` |
| `image.repository` | The image repository to use. | `nginx` |
| `image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `image.tag` | The image tag to use. | `""` |
| `imagePullSecrets` | A list of image pull secrets. | `[]` |
| `nameOverride` | A name to override the default name. | `""` |
| `fullnameOverride` | A name to override the default full name. | `""` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.automount` | Whether to automatically mount a ServiceAccount's API credentials. | `true` |
| `serviceAccount.annotations` | Annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account to use. | `""` |
| `podAnnotations` | Annotations to add to the pod. | `{}` |
| `podLabels` | Labels to add to the pod. | `{}` |
| `podSecurityContext` | The security context for the pod. | `{}` |
| `securityContext` | The security context for the container. | `{}` |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.ports` | A list of ports to expose. | `[{"name":"grpc","port":80,"protocol":"TCP","targetPort":80}]` |
| `container.ports` | A list of ports to expose on the container. | `[{"name":"grpc","containerPort":80,"protocol":"TCP"}]` |
| `persistence.enabled` | Whether to enable persistence. | `true` |
| `persistence.data` | A list of persistent volumes to create. | `[{"name":"vault","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/vault"},{"name":"json","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/json"},{"name":"log-takakrypt","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/var/log/takakrypt"}]` |
| `ingress.enabled` | Whether to enable ingress. | `false` |
| `ingress.className` | The class of ingress to use. | `""` |
| `ingress.annotations` | Annotations to add to the ingress. | `{}` |
| `ingress.hosts` | A list of hosts to expose. | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` |
| `ingress.tls` | A list of TLS secrets to use. | `[]` |
| `application.enabled` | Whether to enable the application. | `true` |
| `application.env` | A list of environment variables to set. | `[{"name":"HELM_TEMPLATE_NAME","value":"taka-auth"}]` |
| `rbac.create` | Whether to create RBAC resources. | `false` |
| `rbac.data` | A list of RBAC resources to create. | `[]` |
| `probe.enabled` | Whether to enable probes. | `false` |
| `resources` | The resources to allocate to the container. | `{}` |
| `autoscaling.enabled` | Whether to enable autoscaling. | `false` |
| `autoscaling.minReplicas` | The minimum number of replicas to scale to. | `1` |
| `autoscaling.maxReplicas` | The maximum number of replicas to scale to. | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to scale on. | `60` |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to scale on. | `60` |
| `nodeSelector.enabled` | Whether to enable node selection. | `false` |
| `nodeSelector.select` | The node selector to use. | `{"node":"default"}` |
| `tolerations` | A list of tolerations to apply to the pod. | `[]` |
| `affinity` | The affinity to apply to the pod. | `{}` |

### backup-service

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of replicas to deploy. | `1` |
| `secret.enabled` | Whether to create secrets. | `false` |
| `secret.data` | A list of secrets to create. | `[]` |
| `configMap.enabled` | Whether to create config maps. | `false` |
| `configMap.data` | A list of config maps to create. | `[]` |
| `image.repository` | The image repository to use. | `nginx` |
| `image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `image.tag` | The image tag to use. | `""` |
| `imagePullSecrets` | A list of image pull secrets. | `[]` |
| `nameOverride` | A name to override the default name. | `""` |
| `fullnameOverride` | A name to override the default full name. | `""` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.automount` | Whether to automatically mount a ServiceAccount's API credentials. | `true` |
| `serviceAccount.annotations` | Annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account to use. | `""` |
| `podAnnotations` | Annotations to add to the pod. | `{}` |
| `podLabels` | Labels to add to the pod. | `{}` |
| `podSecurityContext` | The security context for the pod. | `{}` |
| `securityContext` | The security context for the container. | `{}` |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.ports` | A list of ports to expose. | `[{"name":"grpc","port":80,"protocol":"TCP","targetPort":80}]` |
| `container.ports` | A list of ports to expose on the container. | `[{"name":"grpc","containerPort":80,"protocol":"TCP"}]` |
| `persistence.enabled` | Whether to enable persistence. | `true` |
| `persistence.data` | A list of persistent volumes to create. | `[{"name":"vault","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/vault"},{"name":"json","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/json"},{"name":"log-takakrypt","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/var/log/takakrypt"}]` |
| `ingress.enabled` | Whether to enable ingress. | `false` |
| `ingress.className` | The class of ingress to use. | `""` |
| `ingress.annotations` | Annotations to add to the ingress. | `{}` |
| `ingress.hosts` | A list of hosts to expose. | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` |
| `ingress.tls` | A list of TLS secrets to use. | `[]` |
| `application.enabled` | Whether to enable the application. | `true` |
| `application.env` | A list of environment variables to set. | `[{"name":"HELM_TEMPLATE_NAME","value":"taka-backup"}]` |
| `rbac.create` | Whether to create RBAC resources. | `false` |
| `rbac.data` | A list of RBAC resources to create. | `[]` |
| `probe.enabled` | Whether to enable probes. | `false` |
| `resources` | The resources to allocate to the container. | `{}` |
| `autoscaling.enabled` | Whether to enable autoscaling. | `false` |
| `autoscaling.minReplicas` | The minimum number of replicas to scale to. | `1` |
| `autoscaling.maxReplicas` | The maximum number of replicas to scale to. | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to scale on. | `60` |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to scale on. | `60` |
| `nodeSelector.enabled` | Whether to enable node selection. | `false` |
| `nodeSelector.select` | The node selector to use. | `{"node":"default"}` |
| `tolerations` | A list of tolerations to apply to the pod. | `[]` |
| `affinity` | The affinity to apply to the pod. | `{}` |

### crypto-service

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of replicas to deploy. | `1` |
| `secret.enabled` | Whether to create secrets. | `false` |
| `secret.data` | A list of secrets to create. | `[]` |
| `configMap.enabled` | Whether to create config maps. | `false` |
| `configMap.data` | A list of config maps to create. | `[]` |
| `image.repository` | The image repository to use. | `nginx` |
| `image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `image.tag` | The image tag to use. | `""` |
| `imagePullSecrets` | A list of image pull secrets. | `[]` |
| `nameOverride` | A name to override the default name. | `""` |
| `fullnameOverride` | A name to override the default full name. | `""` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.automount` | Whether to automatically mount a ServiceAccount's API credentials. | `true` |
| `serviceAccount.annotations` | Annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account to use. | `""` |
| `podAnnotations` | Annotations to add to the pod. | `{}` |
| `podLabels` | Labels to add to the pod. | `{}` |
| `podSecurityContext` | The security context for the pod. | `{}` |
| `securityContext` | The security context for the container. | `{}` |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.ports` | A list of ports to expose. | `[{"name":"grpc","port":80,"protocol":"TCP","targetPort":80}]` |
| `container.ports` | A list of ports to expose on the container. | `[{"name":"grpc","containerPort":80,"protocol":"TCP"}]` |
| `persistence.enabled` | Whether to enable persistence. | `true` |
| `persistence.data` | A list of persistent volumes to create. | `[{"name":"vault","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/vault"},{"name":"json","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/json"},{"name":"log-takakrypt","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/var/log/takakrypt"}]` |
| `ingress.enabled` | Whether to enable ingress. | `false` |
| `ingress.className` | The class of ingress to use. | `""` |
| `ingress.annotations` | Annotations to add to the ingress. | `{}` |
| `ingress.hosts` | A list of hosts to expose. | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` |
| `ingress.tls` | A list of TLS secrets to use. | `[]` |
| `application.enabled` | Whether to enable the application. | `true` |
| `application.env` | A list of environment variables to set. | `[{"name":"HELM_TEMPLATE_NAME","value":"taka-crypto"}]` |
| `rbac.create` | Whether to create RBAC resources. | `false` |
| `rbac.data` | A list of RBAC resources to create. | `[]` |
| `probe.enabled` | Whether to enable probes. | `false` |
| `resources` | The resources to allocate to the container. | `{}` |
| `autoscaling.enabled` | Whether to enable autoscaling. | `false` |
| `autoscaling.minReplicas` | The minimum number of replicas to scale to. | `1` |
| `autoscaling.maxReplicas` | The maximum number of replicas to scale to. | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to scale on. | `60` |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to scale on. | `60` |
| `nodeSelector.enabled` | Whether to enable node selection. | `false` |
| `nodeSelector.select` | The node selector to use. | `{"node":"default"}` |
| `tolerations` | A list of tolerations to apply to the pod. | `[]` |
| `affinity` | The affinity to apply to the pod. | `{}` |

### dispatch-service

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of replicas to deploy. | `1` |
| `secret.enabled` | Whether to create secrets. | `false` |
| `secret.data` | A list of secrets to create. | `[]` |
| `configMap.enabled` | Whether to create config maps. | `false` |
| `configMap.data` | A list of config maps to create. | `[]` |
| `image.repository` | The image repository to use. | `nginx` |
| `image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `image.tag` | The image tag to use. | `""` |
| `imagePullSecrets` | A list of image pull secrets. | `[]` |
| `nameOverride` | A name to override the default name. | `""` |
| `fullnameOverride` | A name to override the default full name. | `""` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.automount` | Whether to automatically mount a ServiceAccount's API credentials. | `true` |
| `serviceAccount.annotations` | Annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account to use. | `""` |
| `podAnnotations` | Annotations to add to the pod. | `{}` |
| `podLabels` | Labels to add to the pod. | `{}` |
| `podSecurityContext` | The security context for the pod. | `{}` |
| `securityContext` | The security context for the container. | `{}` |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.ports` | A list of ports to expose. | `[{"name":"grpc","port":80,"protocol":"TCP","targetPort":80}]` |
| `container.ports` | A list of ports to expose on the container. | `[{"name":"grpc","containerPort":80,"protocol":"TCP"}]` |
| `persistence.enabled` | Whether to enable persistence. | `true` |
| `persistence.data` | A list of persistent volumes to create. | `[{"name":"vault","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/vault"},{"name":"json","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/json"},{"name":"log-takakrypt","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/var/log/takakrypt"}]` |
| `ingress.enabled` | Whether to enable ingress. | `false` |
| `ingress.className` | The class of ingress to use. | `""` |
| `ingress.annotations` | Annotations to add to the ingress. | `{}` |
| `ingress.hosts` | A list of hosts to expose. | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` |
| `ingress.tls` | A list of TLS secrets to use. | `[]` |
| `application.enabled` | Whether to enable the application. | `true` |
| `application.env` | A list of environment variables to set. | `[{"name":"HELM_TEMPLATE_NAME","value":"taka-dispatch"}]` |
| `rbac.create` | Whether to create RBAC resources. | `false` |
| `rbac.data` | A list of RBAC resources to create. | `[]` |
| `probe.enabled` | Whether to enable probes. | `false` |
| `resources` | The resources to allocate to the container. | `{}` |
| `autoscaling.enabled` | Whether to enable autoscaling. | `false` |
| `autoscaling.minReplicas` | The minimum number of replicas to scale to. | `1` |
| `autoscaling.maxReplicas` | The maximum number of replicas to scale to. | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to scale on. | `60` |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to scale on. | `60` |
| `nodeSelector.enabled` | Whether to enable node selection. | `false` |
| `nodeSelector.select` | The node selector to use. | `{"node":"default"}` |
| `tolerations` | A list of tolerations to apply to the pod. | `[]` |
| `affinity` | The affinity to apply to the pod. | `{}` |

### gateway-service

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of replicas to deploy. | `1` |
| `secret.enabled` | Whether to create secrets. | `false` |
| `secret.data` | A list of secrets to create. | `[]` |
| `configMap.enabled` | Whether to create config maps. | `false` |
| `configMap.data` | A list of config maps to create. | `[]` |
| `image.repository` | The image repository to use. | `nginx` |
| `image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `image.tag` | The image tag to use. | `""` |
| `imagePullSecrets` | A list of image pull secrets. | `[]` |
| `nameOverride` | A name to override the default name. | `""` |
| `fullnameOverride` | A name to override the default full name. | `""` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.automount` | Whether to automatically mount a ServiceAccount's API credentials. | `true` |
| `serviceAccount.annotations` | Annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account to use. | `""` |
| `podAnnotations` | Annotations to add to the pod. | `{}` |
| `podLabels` | Labels to add to the pod. | `{}` |
| `podSecurityContext` | The security context for the pod. | `{}` |
| `securityContext` | The security context for the container. | `{}` |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.ports` | A list of ports to expose. | `[{"name":"grpc","port":80,"protocol":"TCP","targetPort":80}]` |
| `container.ports` | A list of ports to expose on the container. | `[{"name":"grpc","containerPort":80,"protocol":"TCP"}]` |
| `persistence.enabled` | Whether to enable persistence. | `false` |
| `persistence.data` | A list of persistent volumes to create. | `[]` |
| `ingress.enabled` | Whether to enable ingress. | `false` |
| `ingress.className` | The class of ingress to use. | `""` |
| `ingress.annotations` | Annotations to add to the ingress. | `{}` |
| `ingress.hosts` | A list of hosts to expose. | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` |
| `ingress.tls` | A list of TLS secrets to use. | `[]` |
| `application.enabled` | Whether to enable the application. | `true` |
| `application.env` | A list of environment variables to set. | `[{"name":"HELM_TEMPLATE_NAME","value":"taka-gateway"}]` |
| `rbac.create` | Whether to create RBAC resources. | `false` |
| `rbac.data` | A list of RBAC resources to create. | `[]` |
| `probe.enabled` | Whether to enable probes. | `false` |
| `resources` | The resources to allocate to the container. | `{}` |
| `autoscaling.enabled` | Whether to enable autoscaling. | `false` |
| `autoscaling.minReplicas` | The minimum number of replicas to scale to. | `1` |
| `autoscaling.maxReplicas` | The maximum number of replicas to scale to. | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to scale on. | `60` |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to scale on. | `60` |
| `nodeSelector.enabled` | Whether to enable node selection. | `false` |
| `nodeSelector.select` | The node selector to use. | `{"node":"default"}` |
| `tolerations` | A list of tolerations to apply to the pod. | `[]` |
| `affinity` | The affinity to apply to the pod. | `{}` |

### masking-service

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of replicas to deploy. | `1` |
| `secret.enabled` | Whether to create secrets. | `false` |
| `secret.data` | A list of secrets to create. | `[]` |
| `configMap.enabled` | Whether to create config maps. | `false` |
| `configMap.data` | A list of config maps to create. | `[]` |
| `image.repository` | The image repository to use. | `nginx` |
| `image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `image.tag` | The image tag to use. | `""` |
| `imagePullSecrets` | A list of image pull secrets. | `[]` |
| `nameOverride` | A name to override the default name. | `""` |
| `fullnameOverride` | A name to override the default full name. | `""` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.automount` | Whether to automatically mount a ServiceAccount's API credentials. | `true` |
| `serviceAccount.annotations` | Annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account to use. | `""` |
| `podAnnotations` | Annotations to add to the pod. | `{}` |
| `podLabels` | Labels to add to the pod. | `{}` |
| `podSecurityContext` | The security context for the pod. | `{}` |
| `securityContext` | The security context for the container. | `{}` |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.ports` | A list of ports to expose. | `[{"name":"grpc","port":80,"protocol":"TCP","targetPort":80}]` |
| `container.ports` | A list of ports to expose on the container. | `[{"name":"grpc","containerPort":80,"protocol":"TCP"}]` |
| `persistence.enabled` | Whether to enable persistence. | `true` |
| `persistence.data` | A list of persistent volumes to create. | `[{"name":"vault","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/vault"},{"name":"json","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/opt/app/json"},{"name":"log-takakrypt","accessMode":"ReadWriteMany","size":"5Gi","storageClass":"nfs-csi","mountPath":"/var/log/takakrypt"}]` |
| `ingress.enabled` | Whether to enable ingress. | `false` |
| `ingress.className` | The class of ingress to use. | `""` |
| `ingress.annotations` | Annotations to add to the ingress. | `{}` |
| `ingress.hosts` | A list of hosts to expose. | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` |
| `ingress.tls` | A list of TLS secrets to use. | `[]` |
| `application.enabled` | Whether to enable the application. | `true` |
| `application.env` | A list of environment variables to set. | `[{"name":"HELM_TEMPLATE_NAME","value":"taka-masking"}]` |
| `rbac.create` | Whether to create RBAC resources. | `false` |
| `rbac.data` | A list of RBAC resources to create. | `[]` |
| `probe.enabled` | Whether to enable probes. | `false` |
| `resources` | The resources to allocate to the container. | `{}` |
| `autoscaling.enabled` | Whether to enable autoscaling. | `false` |
| `autoscaling.minReplicas` | The minimum number of replicas to scale to. | `1` |
| `autoscaling.maxReplicas` | The maximum number of replicas to scale to. | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | The target CPU utilization percentage to scale on. | `60` |
| `autoscaling.targetMemoryUtilizationPercentage` | The target memory utilization percentage to scale on. | `60` |
| `nodeSelector.enabled` | Whether to enable node selection. | `false` |
| `nodeSelector.select` | The node selector to use. | `{"node":"default"}` |
| `tolerations` | A list of tolerations to apply to the pod. | `[]` |
| `affinity` | The affinity to apply to the pod. | `{}` |
