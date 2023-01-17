#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
mkdir -p $SCRIPT_DIR/certs/{ca,keycloak,os,os-dashboards}
export OPENSEARCH_DN="/C=AC/ST=AC/L=AC/O=AC/OU=AC"

# Root CA
openssl genrsa -out "$SCRIPT_DIR/certs/ca/root-ca.key" 2048
openssl req -new -x509 -sha256 -days 360 -subj "$OPENSEARCH_DN/CN=CA" -key "$SCRIPT_DIR/certs/ca/root-ca.key" -out "$SCRIPT_DIR/certs/ca/root-ca.pem"

# Admin for security admin script
openssl genrsa -out certs/ca/admin-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/ca/admin-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/ca/admin.key
openssl req -new -subj "$OPENSEARCH_DN/CN=ADMIN" -key certs/ca/admin.key -out certs/ca/admin.csr
openssl x509 -req -in certs/ca/admin.csr -CA certs/ca/root-ca.pem -CAkey certs/ca/root-ca.key -CAcreateserial -sha256 -out certs/ca/admin.pem

# Keycloak
openssl genrsa -out "$SCRIPT_DIR/certs/keycloak/keycloak-temp.key" 2048
openssl pkcs8 -inform PEM -outform PEM -in "$SCRIPT_DIR/certs/keycloak/keycloak-temp.key" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "$SCRIPT_DIR/certs/keycloak/keycloak.key"
openssl req -new -subj "$OPENSEARCH_DN/CN=keycloak" -key "$SCRIPT_DIR/certs/keycloak/keycloak.key"  -out "$SCRIPT_DIR/certs/keycloak/keycloak.csr"
openssl x509 -req -days 360 -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:172.17.0.1,DNS:keycloak") -in "$SCRIPT_DIR/certs/keycloak/keycloak.csr" -CA "$SCRIPT_DIR/certs/ca/root-ca.pem" -CAkey "$SCRIPT_DIR/certs/ca/root-ca.key" -CAcreateserial -sha256 -out "$SCRIPT_DIR/certs/keycloak/keycloak.pem"
cp "$SCRIPT_DIR/certs/keycloak/keycloak.key" "$SCRIPT_DIR/certs/keycloak/tls.key"
cp "$SCRIPT_DIR/certs/keycloak/keycloak.pem" "$SCRIPT_DIR/certs/keycloak/tls.crt"

# Opensearch nodes
openssl genrsa -out "$SCRIPT_DIR/certs/os/os-temp.key" 2048
openssl pkcs8 -inform PEM -outform PEM -in "$SCRIPT_DIR/certs/os/os-temp.key" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "$SCRIPT_DIR/certs/os/os.key"
openssl req -new -subj "$OPENSEARCH_DN/CN=os" -key "$SCRIPT_DIR/certs/os/os.key" -out "$SCRIPT_DIR/certs/os/os.csr"
openssl x509 -req -days 360 -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:os,DNS:opensearch-node1,DNS:opensearch-node2,DNS:opensearch-node3") -in "$SCRIPT_DIR/certs/os/os.csr" -CA "$SCRIPT_DIR/certs/ca/root-ca.pem" -CAkey "$SCRIPT_DIR/certs/ca/root-ca.key" -CAcreateserial -sha256 -out "$SCRIPT_DIR/certs/os/os.pem"

# Opensearch dashboards
openssl genrsa -out "$SCRIPT_DIR/certs/os-dashboards/osd-temp.key" 2048
openssl pkcs8 -inform PEM -outform PEM -in "$SCRIPT_DIR/certs/os-dashboards/osd-temp.key" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "$SCRIPT_DIR/certs/os-dashboards/osd.key"
openssl req -new -subj "$OPENDISTRO_DN/CN=osd" -key "$SCRIPT_DIR/certs/os-dashboards/osd.key" -out "$SCRIPT_DIR/certs/os-dashboards/osd.csr"
openssl x509 -req -days 360 -in "$SCRIPT_DIR/certs/os-dashboards/osd.csr" -CA "$SCRIPT_DIR/certs/ca/root-ca.pem" -CAkey "$SCRIPT_DIR/certs/ca/root-ca.key" -CAcreateserial -sha256 -out "$SCRIPT_DIR/certs/os-dashboards/osd.pem"


chmod 755 -R "$SCRIPT_DIR/certs"
