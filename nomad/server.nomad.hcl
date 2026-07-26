log_level = "INFO"

region = "global"

name = "babucha"

data_dir = "/tmp/nomad-data/"


# Specify the addresses server services to bind to
addresses {
  http = "127.0.0.1"
  serf = "127.0.0.1"
  rpc = "0.0.0.0" #Should be exposed to the public internet
}

# Specify the addresses that other clients and peers can connect to
advertise {
  http = "{DOMAIN}"
  rpc = "{DOMAIN}" 
  serf = "127.0.0.1"
}


server {
  enabled          = true
  bootstrap_expect = 1 #number of servers in cluster to expect
}


# Enable access of UI
ui {
  enabled = true
  show_cli_hints = false
}


tls {
  http = true
  rpc  = true

  ca_file   = "/tmp/nomad-certs/{DOMAIN}-agent-ca.pem"
  cert_file = "/tmp/nomad-certs/global-server-{DOMAIN}.pem"
  key_file  = "/tmp/nomad-certs/global-server-{DOMAIN}-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
