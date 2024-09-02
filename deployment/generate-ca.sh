#!/bin/bash
#
# usage: generate-ca.sh [-f]
#
# Generates a new key and self-signed certificate to be used as the certificate authority (CA).
# Each certificate a node locally generates will be signed by this CA.
#
# All nodes (peers and clients) must use the same certificate.
# If certificate already exists, this script returns with exit status 1,
# unless the -f option is specified (in which case the existing certificate is overwritten).

keyfile="ca.key"
certfile="ca.pem"

if [ -e "$certfile" ] && [ "$1" != "-f" ]; then
    >&2 echo "Certificate file already exists: $certfile"
    >&2 echo "Force overwrite with -f option."
    exit 1
fi

echo
echo "Generating CA key."
touch ~/.rnd
openssl ecparam -genkey -name prime256v1 -out "$keyfile"

echo
echo "Generating CA self-signed certificate."
openssl req -x509 -new -SHA384 -nodes -key "$keyfile" -subj "/C=MR/ST=MR/O=Mir" -days 3650 -out "$certfile"