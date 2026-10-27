# Copyright 2026 Defense Unicorns
# SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

# This config exists while CI tests both Istio sidecar and ambient modes.
variables = {
  minio_operator = {
    ambient = false
  }
}
