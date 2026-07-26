# HashiCorp NOMAD mTLS Set Up

This guide covers setting up a HashiCorp Nomad cluster secured with mutual TLS where certificates are manually managed (use Hashicorp Vault to easily automate the process)

---

### Step 1. Allow RPC Port on Server VPS Firewall
- Allow RPC port (default 4647) in the VPS/firewall that will run the Nomad server agent.
```shell
 ### if using ufw
 sudo ufw allow 4647
```

### Step 2: Generate Cluster Certificates
- Set up the env variables
  ```shell
  export DOMAIN=<demo.com>
  export REGION=global
  ```
- Use certs.sh to generate the CA and server/client certificates for your domain.

---

### Step 3: Nomad Server Configuration & Deployment
- Copy the server certificates and `${DOMAIN}-agent.ca.pem` to the server VPS.
- Update the `server.nomad.hcl` configuration `{DOMAIN}` placeholders and the correct certificate paths.
   
- Start the server agent:
   ```sh
   nomad agent -config server.nomad.hcl
   ```

---

### Step 4: Configure Traefik Proxy(for nomad HTTP traffic)
 - Update traefik/nomad.yaml `{DOMAIN}` placeholder accordingly and apply it to an existing traefik service running on the server VPS.

---

### Step 5: Verify CLI Access
- Set up your environment variables to authenticate securely via mTLS:

```shell
export NOMAD_ADDR="https://${DOMAIN}"
export NOMAD_CACERT="$(pwd)/certs/${DOMAIN}-agent-ca.pem"
export NOMAD_CLIENT_CERT="$(pwd)/certs/client/${REGION}-client-${DOMAIN}.pem"
export NOMAD_CLIENT_KEY="$(pwd)/certs/client/${REGION}-client-${DOMAIN}-key.pem"
```

- Test the connection
```shell
nomad job status 
```

---

### Step 6: Nomad Client Configuration & Deployment
1. Copy the client certificates and `${DOMAIN}-agent.ca.pem` to your client VPS.
2. Update your `client.nomad.hcl` configuration and `{DOMAIN}` placeholders accordingly
3. Start the client agent:
   ```sh
   nomad agent -config client.nomad.hcl
   ```
**Note**: The client can be started with optional introduction token if strict enforcement is required.  Generate the token on cli `nomad node intro create` then provide it `nomad agent -config ./client.nomad.hcl -client-intro-token <TOKEN>`

---

### Step 7: Browser UI Access Setup
1. Generate a client certificate if you haven't already:
   ```shell
   nomad tls cert create -client -domain=${DOMAIN} -additional-dnsname=${DOMAIN} -additional-dnsname=client.${REGION}.nomad

   ```
2. Convert the certificate files into PKCS#12 format for browser import:
   ```shell
   openssl pkcs12 -export -inkey ./${REGION}-client-${DOMAIN}-key.pem -in ./${REGION}-client-${DOMAIN}.pem -out ./${DOMAIN}-browser.pfx
   ```

3. Import the `.pfx` file into your browser's personal certificate store:
   * **Chrome / Brave / Edge**: Settings -> Privacy and security -> Security -> Manage certificates.
   * **Firefox**: Settings -> Privacy & Security -> Certificates -> View Certificates.

4. Import the CA certificate (`nomad.${DOMAIN}-agent.ca.pem`) into your browser or OS trust store as a **Trusted Root Certification Authority**.

5. Navigate to `https://${DOMAIN}` in your browser. A prompt to select the imported certificate will appear if the certificates from step 2 were installed in the OS trust store.
