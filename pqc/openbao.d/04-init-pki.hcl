initialize "pki" {
  request "mount" {
    operation = "create"
    path      = "sys/mounts/pki"
    data = {
      type          = "pki"
      max_lease_ttl = "87600h"
    }
  }

  request "urls" {
    operation = "create"
    path      = "pki/config/urls"
    data = {
      issuing_certificates    = "https://127.0.0.1:8200/v1/pki/ca"
      crl_distribution_points = "https://127.0.0.1:8200/v1/pki/crl"
    }
  }

  # ML-DSA-65 (FIPS 204, security category 3) root CA.
  request "root" {
    operation = "create"
    path      = "pki/root/generate/internal"
    data = {
      common_name = "OpenBao PQC Demo Root CA"
      issuer_name = "pqc-root"
      key_type    = "mldsa"
      # Supported values are: 44, 65 or 87.
      key_bits    = 65
      ttl         = "87600h"
    }
  }

  # ML-DSA leaf certificates for localhost.
  request "role" {
    operation = "create"
    path      = "pki/roles/openbao-server"
    data = {
      key_type           = "mldsa"
      key_bits           = 65
      allowed_domains    = "localhost"
      allow_bare_domains = true
      allow_ip_sans      = true
      ttl                = "720h"
      max_ttl            = "720h"
    }
  }
}
