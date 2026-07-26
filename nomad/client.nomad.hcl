log_level = "INFO"

data_dir = "/tmp/nomad-client/"


client {
  enabled = true
  servers = ["{DOMAIN}"]
}


# Lock the local API completely to localhost
advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}

server {
  enabled          = false
}


ui {
  enabled = false
  show_cli_hints = false
}

# Enable the raw_exec task driver plugin
plugin "raw_exec" {
  config {
    enabled = true
  }
}

tls {
  http = true
  rpc  = true

  ca_file   = "/tmp/nomad-certs/{DOMAIN}-agent-ca.pem"
  cert_file = "/tmp/nomad-certs/global-client-{DOMAIN}.pem"
  key_file  = "/tmp/nomad-certs/global-client-{DOMAIN}-key.pem"

  verify_server_hostname = true
}