#!/usr/bin/env bash
# Copyright (C) Wazuh Inc.
#
# Issues <out>.pem and <out>-key.pem from the CA of a distributed deployment, on the control node.
# Same profile as the installation assistant's certificates tool: RSA 2048 with the key in PKCS#8 (the
# indexer reads no other form), SHA-256, valid ten years, basicConstraints critical CA:FALSE, keyUsage
# critical digitalSignature + keyEncipherment, the given extendedKeyUsage and subject alternative names.
#
# notBefore is backdated one day, so a host whose clock lags the control node does not refuse a freshly
# issued certificate. That is why it goes through "openssl ca": its -startdate exists in every OpenSSL
# and LibreSSL release, while "openssl x509 -req -not_before" only exists from OpenSSL 3.5 on.
#
# Usage: wazuh-issue-pair.sh --ca-dir DIR --out PREFIX --cn NAME --eku EKU [--san LIST] [--cn-first] [--chain]
#   --ca-dir    directory holding root-ca.pem and root-ca.key
#   --out       path prefix of the pair to write (<out>.pem, <out>-key.pem)
#   --cn        common name
#   --eku       extendedKeyUsage, e.g. "serverAuth,clientAuth"
#   --san       subjectAltName entries, comma separated, e.g. "DNS:node-1,IP:10.0.0.1"
#   --cn-first  subject with the CN first, as the indexer package writes nodes_dn and admin_dn
#   --chain     append the CA certificate to the leaf (servers that hand their chain to peers)

set -euo pipefail
umask 077

ca_dir="" out="" cn="" eku="" san="" cn_first="" chain=""
while [ $# -gt 0 ]; do
    case "$1" in
        --ca-dir) ca_dir="$2"; shift 2 ;;
        --out) out="$2"; shift 2 ;;
        --cn) cn="$2"; shift 2 ;;
        --eku) eku="$2"; shift 2 ;;
        --san) san="$2"; shift 2 ;;
        --cn-first) cn_first=1; shift ;;
        --chain) chain=1; shift ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done
for required in ca_dir out cn eku; do
    if [ -z "${!required}" ]; then
        echo "missing --${required//_/-}" >&2
        exit 2
    fi
done

# GNU date first, then the BSD date of a macOS control node. Two-digit years: OpenSSL reads them as
# 20YY below 50, and a ten-year certificate ends well before 2049.
utc_date() {
    date -u -d "$1" '+%y%m%d%H%M%SZ' 2>/dev/null || date -u -v"$2" '+%y%m%d%H%M%SZ'
}
start_date=$(utc_date '-1 day' '-1d')
end_date=$(utc_date '+3650 days' '+3650d')

if [ -n "${cn_first}" ]; then
    subject="/CN=${cn}/OU=Wazuh/O=Wazuh/L=California/C=US"
else
    subject="/C=US/L=California/O=Wazuh/OU=Wazuh/CN=${cn}"
fi

work=$(mktemp -d)
trap 'rm -rf "${work}"' EXIT

openssl genrsa -out "${work}/rsa.pem" 2048 2>/dev/null
openssl pkcs8 -topk8 -nocrypt -in "${work}/rsa.pem" -out "${work}/key.pem"
openssl req -new -key "${work}/key.pem" -subj "${subject}" -out "${work}/req.csr"

{
    printf '%s\n' "[ leaf ]"
    printf '%s\n' "basicConstraints = critical,CA:FALSE"
    printf '%s\n' "keyUsage = critical,digitalSignature,keyEncipherment"
    printf '%s\n' "extendedKeyUsage = ${eku}"
    printf '%s\n' "subjectKeyIdentifier = hash"
    printf '%s\n' "authorityKeyIdentifier = keyid,issuer"
    if [ -n "${san}" ]; then
        printf '%s\n' "subjectAltName = ${san}"
    fi
} > "${work}/leaf.ext"

# A single-use CA workspace: a random serial and no unique-subject rule. openssl ca lays the subject out
# in the order of the policy section, whatever the request says, so the policy carries the order wanted.
mkdir "${work}/newcerts"
: > "${work}/index.txt"
printf '%s\n' "unique_subject = no" > "${work}/index.txt.attr"
openssl rand -hex 16 > "${work}/serial"
cat > "${work}/ca.conf" <<EOF
[ ca ]
default_ca = deployment_ca

[ deployment_ca ]
dir = ${work}
database = ${work}/index.txt
serial = ${work}/serial
new_certs_dir = ${work}/newcerts
certificate = ${ca_dir}/root-ca.pem
private_key = ${ca_dir}/root-ca.key
default_md = sha256
email_in_dn = no
policy = any

[ any ]
EOF
if [ -n "${cn_first}" ]; then
    printf '%s\n' "commonName = supplied" "organizationalUnitName = optional" "organizationName = optional" \
        "localityName = optional" "countryName = optional" >> "${work}/ca.conf"
else
    printf '%s\n' "countryName = optional" "localityName = optional" "organizationName = optional" \
        "organizationalUnitName = optional" "commonName = supplied" >> "${work}/ca.conf"
fi

openssl ca -batch -notext -config "${work}/ca.conf" -in "${work}/req.csr" -out "${work}/leaf.pem" \
    -extfile "${work}/leaf.ext" -extensions leaf -startdate "${start_date}" -enddate "${end_date}" 2>"${work}/ca.log" \
    || { cat "${work}/ca.log" >&2; exit 1; }

if [ -n "${chain}" ]; then
    cat "${ca_dir}/root-ca.pem" >> "${work}/leaf.pem"
fi

# The key first and the certificate last: the certificate is what marks the pair as issued.
mv "${work}/key.pem" "${out}-key.pem"
mv "${work}/leaf.pem" "${out}.pem"
