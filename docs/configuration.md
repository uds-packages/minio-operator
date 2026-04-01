# Configuration

Minio is configured through the upstream [Minio Operator and Tenant charts](https://github.com/minio/operator/tree/master/helm) as well as a UDS configuration chart that supports the following:

## Networking

Network policies are controlled via the `uds-minio-config` chart in accordance with the [common patterns for networking within UDS Software Factory](https://github.com/defenseunicorns/uds-software-factory/blob/main/docs/networking.md).  Because minio does not interact with external resources like databases or object storage it only implements `custom` networking for the `minio` tenant namespace.

## Storage Pools

The Minio Operator package by default deploys a minimal resource footprint as to work in CI jobs and on lower resourced systems. Due to limitations with Zarf variables, the size of the storage pool cannot be overridden at the package level and can only happen as a bundle override. To override the storage pool, provide a bundle override to this package following the below pattern:

```yaml
packages:
  - name: minio-operator
    path: ../
    # x-release-please-start-version
    ref: 6.0.2-uds.0
    # x-release-please-end
    overrides:
      minio-operator:
        minio-tenant:
          values:
            - path: tenant.pools
              value:
                - servers: 4
                  name: pool-0
                  volumesPerServer: 4
                  size: 10Gi
```

## Exposing MinIO Storage Pool parameters for deploy-time overrides.

When importing this package into a UDS Bundle, the storage pool parameters can
also be exposed as variables for deploy-time overrides. This can be done by
adding the following to the component's `overrides` section, as an example:

```yaml
packages:
  ...
  - name: minio-operator-package
    overrides:
      minio-operator:
        minio-tenant:
          variables:
            - name: MINIO_POOL_NAME
              path: "tenant.pools[0].name"
              description: "MinIO's Pool Name"
              default: "pool-0"
            - name: MINIO_VOLSPER_SERVER
              path: "tenant.pools[0].volumesPerServer"
              description: "Number of volumes per server"
              default: "4"
            - name: MINIO_SERVERS
              path: "tenant.pools[0].servers"
              description: "Number of MinIO servers"
              default: "1"
            - name: MINIO_PVC_SIZE
              path: "tenant.pools[0].size"
              description: "MinIO PVC Size"
              default: "2Gi"
```

Now these variables can be set at deploy-time using the `--set` flag, as an example:

```shell
uds deploy my-bundle --set MINIO_POOL_NAME=pool-1 --set MINIO_VOLSPER_SERVER=2 --set MINIO_SERVERS=2 --set MINIO_PVC_SIZE=5Gi
```

For more details on storage pool requirements see the [Minio documentation](https://min.io/docs/minio/kubernetes/upstream/reference/operator-crd.html#pool).

## Resource Provisioning

This package facilitates the ability to provision multiple sets of buckets for a given "app" as well as a policy and credentials scoped to those specific buckets. To enable this resource creation, you must provide certain details in UDS bundle overrides. For example:

```yaml
  - name: minio-operator
    path: ../
    # x-release-please-start-version
    ref: 6.0.2-uds.0
    # x-release-please-end
    overrides:
      minio-operator:
        uds-minio-config:
          values:
            # Helm overrides to proviion resources in the minio tenant
            - path: apps
              value:
                # a list of resources can be provided here in the following format.
                - name: mc-cli # App name.
                  # The following three fields are used to create an ingress rule into the minio tenant for your app
                  user: mc-cli # "Access Key ID" for the scoped credential. Note: this cannot be reused and cannot be the same as the root minio credential.
                  namespace: mc-cli # App namespace
                  remoteSelector:
                    job-name: minio-job # Selector of the app that will be connecting to minio
                  bucketNames: # list of buckets to be provisioned in tenant scoped to the app
                    - mc-cli-test-bucket
                  policy: "" # Optional: template-able policy override for the scoped resources if the standard policy does not meet the needs of the application.
                  copyPassword: # Whether to copy the secret to the apps namespace. Must be true or false. See below section of this page for more details.
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

Currently SSO for minio is not fully integrated with uds-core. To enable SSO on your deployment, some additional steps are required. First follow the [Minio keycloak setup guide](https://min.io/docs/minio/macos/operations/external-iam/configure-keycloak-identity-management.html) for generating a client in keycloak with the clientid in the format of `<minio-tenant-name>-sso` and configuring the correct protocol mappers and user attribute assignments. Next, in your bundle, override `sso.enabled` in the config chart to `true` and provide the client secret via the `identityOpenidClientSecret` config chart value.

## Network Encryption

In line with the UDS philosophy of having the underlying platform meet as many security controls as possible, network encryption at the app layer is disabled in this package. Network encryption is facilitated by Istio mTLS.

## Volume Encryption

In line with the UDS philosophy of having the underlying platform meet as many security controls as possible, volume encryption at the app layer is disabled in this package. Volume encryption should be provided by the underlying storage class being used to provision minio volumes.
