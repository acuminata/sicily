#!/bin/sh

DOMAIN="${DOMAIN:-nomad.murage.in}"
REGION="${REGION:-global}"
DAYS=365
CERTS_BASE_DIR="./certs"

# Navigate into the directory so nomad tls outputs files directly there
mkdir -p "${CERTS_BASE_DIR}"  && cd "${CERTS_BASE_DIR}" || exit 1


# Create CA certificate
nomad tls ca create -name-constraint=true -domain=${DOMAIN}

# Create server certificate
nomad tls cert create -server -domain=${DOMAIN} -days=${DAYS} -region=${REGION} -additional-dnsname=${DOMAIN} -additional-dnsname=server.${REGION}.nomad
 
# Create client certificate
nomad tls cert create -client -domain=${DOMAIN}  -days=${DAYS} -additional-dnsname=${DOMAIN} -additional-dnsname=client.${REGION}.nomad


# Convert the browser certificates for import - https://stackoverflow.com/a/70836557
openssl pkcs12 -export -inkey ./${REGION}-client-${DOMAIN}-key.pem  -in ./${REGION}-client-${DOMAIN}.pem -out ./${DOMAIN}-browser.pfx



# Move files into their respective subdirectories

SERVER_DIR="server/"
CLIENT_DIR="client/"
BROWSER_DIR="browser/"

mkdir -p "${SERVER_DIR}" "${CLIENT_DIR}" "${BROWSER_DIR}"

mv "${REGION}-server-"* "${SERVER_DIR}"
cp "${DOMAIN}-agent-ca.pem" "${SERVER_DIR}"

mv "${REGION}-client-"* "${CLIENT_DIR}"
cp "${DOMAIN}-agent-ca.pem" "${CLIENT_DIR}"

mv "${DOMAIN}-browser.pfx" "${BROWSER_DIR}"

echo "Certificates successfully organized under ${CERTS_BASE_DIR}/"