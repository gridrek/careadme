#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if a file exists and remove it
check_and_remove_file() {
    if [ -f "$1" ]; then
        echo "Warning: File $1 already exists. Removing it."
        rm "$1"
    fi
}

# Check and remove all files before proceeding
check_and_remove_file "ca.key"
check_and_remove_file "ca.csr"
check_and_remove_file "ca.crt"
check_and_remove_file "client.key"
check_and_remove_file "server.key"
check_and_remove_file "broker.key"
check_and_remove_file "client.csr"
check_and_remove_file "server.csr"
check_and_remove_file "broker.csr"
check_and_remove_file "client.crt"
check_and_remove_file "server.crt"
check_and_remove_file "broker.crt"

# Generate the CA private key
openssl genrsa -out ca.key 2048
echo "Private key (ca.key) generated."

# Create the CA CSR
openssl req -config ca.cnf -new -key ca.key -out ca.csr
echo "CSR (ca.csr) generated using ca.cnf."

# Create the root certificate
openssl x509 -req -days 365 -signkey ca.key -in ca.csr -out ca.crt -extfile ca.cnf -extensions v3_ca
echo "Root certificate (ca.crt) generated."

# Generate private keys for client, server, and broker
openssl genrsa -out client.key 2048
echo "Client private key (client.key) generated."

openssl genrsa -out server.key 2048
echo "Server private key (server.key) generated."

openssl genrsa -out broker.key 2048
echo "Broker private key (broker.key) generated."

# Create the CSRs for client, server, and broker
openssl req -new -key client.key -out client.csr -config client.cnf
echo "Client CSR (client.csr) generated using client.cnf."

openssl req -new -key server.key -out server.csr -config server.cnf
echo "Server CSR (server.csr) generated using server.cnf."

openssl req -new -key broker.key -out broker.csr -config broker.cnf
echo "Broker CSR (broker.csr) generated using broker.cnf."

# Sign the client CSR and include SAN
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out client.crt -days 365 -sha256 -extfile client.cnf -extensions v3_req
echo "Client certificate (client.crt) signed by CA."

# Sign the server CSR and include SAN
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out server.crt -days 365 -sha256 -extfile server.cnf -extensions v3_req
echo "Server certificate (server.crt) signed by CA."

# Sign the broker CSR and include SAN
openssl x509 -req -in broker.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out broker.crt -days 365 -sha256 -extfile broker.cnf -extensions v3_req
echo "Broker certificate (broker.crt) signed by CA."


# Instructions for distributing certificates
echo "Certificates and keys generated successfully. Distribute client.crt, server.crt, and broker.crt to respective entities."

check_and_remove_file "../server/cert/server.crt"
check_and_remove_file "../server/cert/ca.crt"
check_and_remove_file "../server/cert/server.key"

check_and_remove_file "../broker/cert/broker.crt"
check_and_remove_file "../broker/cert/ca.crt"
check_and_remove_file "../broker/cert/broker.key"


cp server.crt ../server/cert/server.crt
cp ca.crt ../server/cert/ca.crt
cp server.key ../server/cert/server.key

cp broker.crt ../broker/cert/broker.crt
cp ca.crt ../broker/cert/ca.crt
cp broker.key ../broker/cert/broker.key