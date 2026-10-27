# Copyright 2026 Defense Unicorns
# SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

uds {
  bundle_api_version = "uds.dev/v1alpha1"
}

metadata {
  name        = "minio-test"
  description = "A UDS Bundle for minio operator (+tenant)"
  version     = "dev"
}

package "minio-operator" {
  source       = "../zarf-package-minio-operator-${sys.arch}-dev.tar.zst"
  values_files = ["values/minio-operator.yaml"]

  signature_verification {
    verify = false
  }
}
