storage "raft" {
  path    = "data/raft"
  node_id = "pqc-node-1"
}

api_addr     = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui           = true

# Show initialization in stdout
audit "file" "stdout" {
  description = "Audit log to stdout"
  options {
    file_path = "stdout"
  }
}
