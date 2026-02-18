# 🏭 UDS Minio Operator Package

[<img alt="Made for UDS" src="https://raw.githubusercontent.com/defenseunicorns/uds-common/refs/heads/main/docs/assets/made-for-uds-bronze.svg" height="20px"/>](https://github.com/defenseunicorns/uds-core)
[![Latest Release](https://img.shields.io/github/v/release/uds-packages/minio-operator)](https://github.com/uds-packages/minio-operator/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/uds-packages/minio-operator/release.yaml)](https://github.com/uds-packages/minio-operator/actions/workflows/release.yaml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/uds-packages/minio-operator/badge)](https://api.securityscorecards.dev/projects/github.com/uds-packages/minio-operator)

> [!NOTE]
> `minio-operator` is only a Bronze package and does not support all minio-operator features yet! If you would like to improve the package we welcome PRs! (see [Contributing](#contributing) below)

This package is designed for use as part of a [UDS Software Factory](https://github.com/defenseunicorns/uds-software-factory) bundle deployed on [UDS Core](https://github.com/defenseunicorns/uds-core).

> The MinIO Operator simplifies the deployment and management of MinIO object storage clusters on Kubernetes. It automates the provisioning, scaling, and maintenance of MinIO instances, ensuring high availability and performance.

## Prerequisites

This package requires a Kubernetes Cluster providing a Storage Class that has [UDS Core](https://github.com/defenseunicorns/uds-core) installed into it.  You can learn more about configuring this package in the [configuration documentation](./docs/configuration.md)

## Releases

The released packages can be found in [ghcr](https://github.com/uds-packages/minio-operator/pkgs/container/minio-operator)).

## UDS Tasks (for local dev and CI)

*For local dev, this requires you install [uds-cli](https://github.com/defenseunicorns/uds-cli?tab=readme-ov-file#install)

> :white_check_mark: **Tip:** To get a list of tasks to run you can use `uds run --list`!

## Contributing

Please see the [CONTRIBUTING.md](./CONTRIBUTING.md)

## Development

When developing this package it is ideal to utilize the json schemas for UDS Bundles, Zarf Packages and Maru Tasks. This involves configuring your IDE to provide schema validation for the respective files used by each application. For guidance on how to set up this schema validation, please refer to the [guide](https://github.com/defenseunicorns/uds-common/blob/main/docs/development-ide-configuration.md) in uds-common.
