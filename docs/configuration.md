# Configuration

Minio is configured through the upstream [Minio Operator and Tenant charts](https://github.com/minio/operator/tree/master/helm) as well as a UDS configuration chart that supports the following:

## Networking

Network policies are controlled via the `uds-minio-config` chart and follow [similar networking patterns as the Reference Package](https://github.com/uds-packages/reference-package/blob/main/docs/networking-patterns.md).

The built-in tenant uses the `minio` namespace. When the operator also manages tenants in other namespaces, configure `operatorAdditionalNetworkAllow` on `uds-minio-config` through a [Next bundle values file](../bundle/values/minio-operator.yaml). Operator-to-tenant management traffic uses port 9000, while tenants use the operator's port 4221 update service during operator-managed upgrades. The upstream operator watches all namespaces by default; if `WATCHED_NAMESPACE` is explicitly set in the operator environment, it must include every target namespace.

```yaml
uds-minio-config:
  operatorAdditionalNetworkAllow:
    - direction: Egress
      selector:
        app.kubernetes.io/name: operator
      remoteNamespace: "*"
      port: 9000
      description: MinIO operator communication with tenants
    - direction: Ingress
      selector:
        app.kubernetes.io/name: operator
      remoteNamespace: "*"
      port: 4221
      description: MinIO tenant access to the operator update service
```

Reference this file from the bundle's `package "minio-operator"` block with `values_files = ["values/minio-operator.yaml"]`. The wildcard can be replaced with individual tenant namespaces for a narrower policy. `operatorAdditionalNetworkAllow` is rendered only into the operator `Package`; the existing `additionalNetworkAllow` value remains scoped to the built-in tenant `Package`. Each external tenant's UDS `Package` must provide the reciprocal ingress on port 9000 and egress on port 4221.

## Storage Pools

The Minio Operator package by default deploys a minimal resource footprint to work in CI jobs and on lower resourced systems. To change the storage pool in a Next bundle, add the following to its package values file:

```yaml
minio-tenant:
  tenant:
    pools:
      - servers: 4
        name: pool-0
        volumesPerServer: 4
        size: 10Gi
```

## Exposing MinIO storage pool parameters for deploy-time overrides

When importing this package into a Next bundle, storage pool parameters can also be exposed as bundle variables. Put the following in the package values file:

```yaml
minio-tenant:
  tenant:
    pools:
      - name: {{ .vars.minio_operator.pool_name }}
        volumesPerServer: {{ .vars.minio_operator.volumes_per_server }}
        servers: {{ .vars.minio_operator.servers }}
        size: {{ .vars.minio_operator.pvc_size }}
```

Set these variables in `config.uds.hcl` (or `defaults.uds.hcl` for values embedded in the bundle):

```hcl
variables = {
  minio_operator = {
    pool_name          = "pool-1"
    volumes_per_server = 2
    servers            = 2
    pvc_size           = "5Gi"
  }
}
```

For more details on storage pool requirements see the [Minio documentation](https://min.io/docs/minio/kubernetes/upstream/reference/operator-crd.html#pool).

## Resource Provisioning

This package can provision buckets, policies, and scoped credentials for an application. Add an `apps` list under `uds-minio-config` in the package values file. For example:

```yaml
uds-minio-config:
  apps:
    - name: mc-cli # App name
      user: mc-cli # Access Key ID; must be unique and differ from the root credential
      namespace: mc-cli
      remoteSelector:
        job-name: minio-job
      bucketNames:
        - mc-cli-test-bucket
      policy: "" # Optional scoped policy; empty uses the chart's default
      copyPassword:
        enabled: true
        secretName: ""
        secretIDKey: ""
        secretPasswordKey: ""
```

## Cross-Namespace Password

When a given app is created as demonstrated in the previous section, one can optionally have the scoped credentials in that app replicated to the app namespace via the app scoped copyPassword configuration.

- `copyPassword.enabled`: enables or disables the copying of the minio credential secret to another namespace
- `copyPassword.secretName`: the name to give the Kubernetes secret in the other namespace
- `copyPassword.secretIDKey`: the key for the Access Key ID within the Kubernetes secret
- `copyPassword.secretPasswordKey`: the key for the password within the Kubernetes secret
- `copyPassword.user`: the user or "Access Key ID" for the scoped credential

## SSO

Currently SSO for minio is not fully integrated with uds-core. To enable SSO on your deployment, some additional steps are required. First follow the [Minio keycloak setup guide](https://min.io/docs/minio/macos/operations/external-iam/configure-keycloak-identity-management.html) for generating a client in keycloak with the clientid in the format of `<minio-tenant-name>-sso` and configuring the correct protocol mappers and user attribute assignments. Next, in your bundle values file, set `sso.enabled` in the config chart to `true` and provide the client secret via the `identityOpenidClientSecret` config chart value.

## Network Encryption

In line with the UDS philosophy of having the underlying platform meet as many security controls as possible, network encryption at the app layer is disabled in this package. Network encryption is facilitated by Istio mTLS.

## Volume Encryption

In line with the UDS philosophy of having the underlying platform meet as many security controls as possible, volume encryption at the app layer is disabled in this package. Volume encryption should be provided by the underlying storage class being used to provision minio volumes.
