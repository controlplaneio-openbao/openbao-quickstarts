listener "tcp" {
  address = "127.0.0.1:8200"

  tls_cert_file = "tls/server.pem"
  tls_key_file  = "tls/server-key.pem"

  tls_min_version = "tls13"
  tls_key_exchange_preferences = [
    "X25519MLKEM768",     # hybrid, what browsers and Go clients offer by default
    "SecP384r1MLKEM1024", # hybrid, NIST curve + ML-KEM-1024
    "MLKEM1024",          # pure post-quantum, no classical component
  ]
}
