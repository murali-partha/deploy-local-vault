ui = true

api_addr     = "http://{{ GetPrivateIP }}:8200"
cluster_addr = "http://{{ GetPrivateIP }}:8201"

storage "raft" {
  path = "/opt/vault/data"
  node_id = "raft_node_1"
}

disable_mlock = true
license_path = "/opt/vault/license.hclic"
listener "tcp" {
    address     = "0.0.0.0:8200"
    tls_disable = 1
}