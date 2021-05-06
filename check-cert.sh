#!/bin/bash
set -e

# bonus script :-) - parses the certificate out of a YAML and extracts the validity date
# usage: ./check-cert.sh certificate-file.yaml

[ -z "`which jq`" ] && echo "jq is needed, see https://stedolan.github.io/jq/download/" && exit 1
[ -z "`which yq`" ] && echo "yq is needed, see https://mikefarah.gitbook.io/yq/" && exit 1

valid=$(date --date "`yq e ${1} -j | jq -r '.data."tls.crt"' | base64 -d | openssl x509 -noout -dates | grep 'notAfter=' | cut -d= -f 2 `" +'%Y-%m-%d')
echo "Certificate ${1} is valid until $valid"
