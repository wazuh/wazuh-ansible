#!/usr/bin/env bash

# Wazuh installer
# Copyright (C) 2015, Wazuh Inc.
#
# This program is a free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License (version 2) as published by the FSF - Free Software
# Foundation.
base_path="$(dirname "$(readlink -f "$0")")"
readonly base_path
readonly config_file="${base_path}/config.yml"
readonly logfile=""
cert_tmp_path="/tmp/wazuh-certificates"
debug=">> /dev/null 2>&1"

# ------------ certFunctions.sh ------------ 
function cert_cleanFiles() {

    eval "rm -f ${cert_tmp_path}/*.csr ${debug}"
    eval "rm -f ${cert_tmp_path}/*.srl ${debug}"
    eval "rm -f ${cert_tmp_path}/*.conf ${debug}"
    eval "rm -f ${cert_tmp_path}/admin-key-temp.pem ${debug}"

}
function cert_checkOpenSSL() {

    if [ -z "$(command -v openssl)" ]; then
        common_logger -e "OpenSSL not installed."
        exit 1
    fi

}
function cert_checkRootCA() {

    if  [[ -n ${rootca} || -n ${rootcakey} ]]; then
        # Verify variables match keys
        if [[ ${rootca} == *".key" ]]; then
            ca_temp=${rootca}
            rootca=${rootcakey}
            rootcakey=${ca_temp}
        fi
        # Validate that files exist
        if [[ -e ${rootca} ]]; then
            eval "cp ${rootca} ${cert_tmp_path}/root-ca.pem ${debug}"
        else
            common_logger -e "The file ${rootca} does not exists"
            cert_cleanFiles
            exit 1
        fi
        if [[ -e ${rootcakey} ]]; then
            eval "cp ${rootcakey} ${cert_tmp_path}/root-ca.key ${debug}"
        else
            common_logger -e "The file ${rootcakey} does not exists"
            cert_cleanFiles
            exit 1
        fi
    else
        cert_generateRootCAcertificate
    fi

}
function cert_generateAdmincertificate() {

    eval "openssl genrsa -out ${cert_tmp_path}/admin-key-temp.pem 2048 ${debug}"
    eval "openssl pkcs8 -inform PEM -outform PEM -in ${cert_tmp_path}/admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${cert_tmp_path}/admin-key.pem ${debug}"
    eval "openssl req -new -key ${cert_tmp_path}/admin-key.pem -out ${cert_tmp_path}/admin.csr -batch -subj '/C=US/L=California/O=Wazuh/OU=Wazuh/CN=admin' ${debug}"
    eval "openssl x509 -days 3650 -req -in ${cert_tmp_path}/admin.csr -CA ${cert_tmp_path}/root-ca.pem -CAkey ${cert_tmp_path}/root-ca.key -CAcreateserial -sha256 -out ${cert_tmp_path}/admin.pem ${debug}"

}
function cert_generateCertificateconfiguration() {

    cat > "${cert_tmp_path}/${1}.conf" <<- EOF
        [ req ]
        prompt = no
        default_bits = 2048
        default_md = sha256
        distinguished_name = req_distinguished_name
        x509_extensions = v3_req

        [req_distinguished_name]
        C = US
        L = California
        O = Wazuh
        OU = Wazuh
        CN = cname

        [ v3_req ]
        authorityKeyIdentifier=keyid,issuer
        basicConstraints = CA:FALSE
        keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
        subjectAltName = @alt_names

        [alt_names]
        IP.1 = cip
	EOF

    conf="$(awk '{sub("CN = cname", "CN = '"${1}"'")}1' "${cert_tmp_path}/${1}.conf")"
    echo "${conf}" > "${cert_tmp_path}/${1}.conf"

    isIP=$(echo "${2}" | grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")
    isDNS=$(echo "${2}" | grep -P "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z-]{2,})+$" )

    if [[ -n "${isIP}" ]]; then
        conf="$(awk '{sub("IP.1 = cip", "IP.1 = '"${2}"'")}1' "${cert_tmp_path}/${1}.conf")"
        echo "${conf}" > "${cert_tmp_path}/${1}.conf"
    elif [[ -n "${isDNS}" ]]; then
        conf="$(awk '{sub("CN = cname", "CN =  '"${2}"'")}1' "${cert_tmp_path}/${1}.conf")"
        echo "${conf}" > "${cert_tmp_path}/${1}.conf"
        conf="$(awk '{sub("IP.1 = cip", "DNS.1 = '"${2}"'")}1' "${cert_tmp_path}/${1}.conf")"
        echo "${conf}" > "${cert_tmp_path}/${1}.conf"
    else
        common_logger -e "The given information does not match with an IP address or a DNS."
        exit 1
    fi

}
function cert_generateIndexercertificates() {

    if [ ${#indexer_node_names[@]} -gt 0 ]; then
        common_logger -d "Creating the Wazuh indexer certificates."

        for i in "${!indexer_node_names[@]}"; do
            cert_generateCertificateconfiguration "${indexer_node_names[i]}" "${indexer_node_ips[i]}"
            eval "openssl req -new -nodes -newkey rsa:2048 -keyout ${cert_tmp_path}/${indexer_node_names[i]}-key.pem -out ${cert_tmp_path}/${indexer_node_names[i]}.csr -config ${cert_tmp_path}/${indexer_node_names[i]}.conf -days 3650 ${debug}"
            eval "openssl x509 -req -in ${cert_tmp_path}/${indexer_node_names[i]}.csr -CA ${cert_tmp_path}/root-ca.pem -CAkey ${cert_tmp_path}/root-ca.key -CAcreateserial -out ${cert_tmp_path}/${indexer_node_names[i]}.pem -extfile ${cert_tmp_path}/${indexer_node_names[i]}.conf -extensions v3_req -days 3650 ${debug}"
        done
    else
        return 1
    fi

}
function cert_generateFilebeatcertificates() {

    if [ ${#server_node_names[@]} -gt 0 ]; then
        common_logger -d "Creating the Wazuh server certificates."

        for i in "${!server_node_names[@]}"; do
            cert_generateCertificateconfiguration "${server_node_names[i]}" "${server_node_ips[i]}"
            eval "openssl req -new -nodes -newkey rsa:2048 -keyout ${cert_tmp_path}/${server_node_names[i]}-key.pem -out ${cert_tmp_path}/${server_node_names[i]}.csr -config ${cert_tmp_path}/${server_node_names[i]}.conf -days 3650 ${debug}"
            eval "openssl x509 -req -in ${cert_tmp_path}/${server_node_names[i]}.csr -CA ${cert_tmp_path}/root-ca.pem -CAkey ${cert_tmp_path}/root-ca.key -CAcreateserial -out ${cert_tmp_path}/${server_node_names[i]}.pem -extfile ${cert_tmp_path}/${server_node_names[i]}.conf -extensions v3_req -days 3650 ${debug}"
        done
    else
        return 1
    fi

}
function cert_generateDashboardcertificates() {

    if [ ${#dashboard_node_names[@]} -gt 0 ]; then
        common_logger -d "Creating the Wazuh dashboard certificates."

        for i in "${!dashboard_node_names[@]}"; do
            cert_generateCertificateconfiguration "${dashboard_node_names[i]}" "${dashboard_node_ips[i]}"
            eval "openssl req -new -nodes -newkey rsa:2048 -keyout ${cert_tmp_path}/${dashboard_node_names[i]}-key.pem -out ${cert_tmp_path}/${dashboard_node_names[i]}.csr -config ${cert_tmp_path}/${dashboard_node_names[i]}.conf -days 3650 ${debug}"
            eval "openssl x509 -req -in ${cert_tmp_path}/${dashboard_node_names[i]}.csr -CA ${cert_tmp_path}/root-ca.pem -CAkey ${cert_tmp_path}/root-ca.key -CAcreateserial -out ${cert_tmp_path}/${dashboard_node_names[i]}.pem -extfile ${cert_tmp_path}/${dashboard_node_names[i]}.conf -extensions v3_req -days 3650 ${debug}"
        done
    else
        return 1
    fi

}
function cert_generateRootCAcertificate() {

    common_logger -d "Creating the root certificate."

    eval "openssl req -x509 -new -nodes -newkey rsa:2048 -keyout ${cert_tmp_path}/root-ca.key -out ${cert_tmp_path}/root-ca.pem -batch -subj '/OU=Wazuh/O=Wazuh/L=California/' -days 3650 ${debug}"

}
function cert_parseYaml() {

    local prefix=${2}
    local s='[[:space:]]*'
    local w='[a-zA-Z0-9_]*'
    local fs
    fs=$(echo @|tr @ '\034')
    sed -re "s|^(\s+)-\s+name|\1  name|" "${1}" |
    sed -ne "s|^\($s\):|\1|" \
            -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
    awk -F"$fs" '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=%s\n", "'$prefix'",vn, $2, $3);
        }
    }'

}
function cert_readConfig() {

    if [ -f "${config_file}" ]; then
        if [ ! -s "${config_file}" ]; then
            common_logger -e "File ${config_file} is empty"
            exit 1
        fi
        eval "$(cert_convertCRLFtoLF "${config_file}")"
        common_checkWazuhConfigYaml
        eval "$(cert_parseYaml "${config_file}")"
        eval "indexer_node_names=( $(cert_parseYaml "${config_file}" | grep nodes_indexer__name | sed 's/nodes_indexer__name=//' | sed -r 's/\s+//g') )"
        eval "server_node_names=( $(cert_parseYaml "${config_file}" | grep nodes_server__name | sed 's/nodes_server__name=//' | sed -r 's/\s+//g') )"
        eval "dashboard_node_names=( $(cert_parseYaml "${config_file}" | grep nodes_dashboard__name | sed 's/nodes_dashboard__name=//' | sed -r 's/\s+//g') )"

        eval "indexer_node_ips=( $(cert_parseYaml "${config_file}" | grep nodes_indexer__ip | sed 's/nodes_indexer__ip=//' | sed -r 's/\s+//g') )"
        eval "server_node_ips=( $(cert_parseYaml "${config_file}" | grep nodes_server__ip | sed 's/nodes_server__ip=//' | sed -r 's/\s+//g') )"
        eval "dashboard_node_ips=( $(cert_parseYaml "${config_file}" | grep nodes_dashboard__ip | sed 's/nodes_dashboard__ip=//' | sed -r 's/\s+//g') )"

        eval "server_node_types=( $(cert_parseYaml "${config_file}" | grep nodes_server__node_type | sed 's/nodes_server__node_type=//' | sed -r 's/\s+//g') )"

        unique_names=($(echo "${indexer_node_names[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        if [ "${#unique_names[@]}" -ne "${#indexer_node_names[@]}" ]; then 
            common_logger -e "Duplicated indexer node names."
            exit 1
        fi

        unique_ips=($(echo "${indexer_node_ips[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        if [ "${#unique_ips[@]}" -ne "${#indexer_node_ips[@]}" ]; then 
            common_logger -e "Duplicated indexer node ips."
            exit 1
        fi

        unique_names=($(echo "${server_node_names[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        if [ "${#unique_names[@]}" -ne "${#server_node_names[@]}" ]; then 
            common_logger -e "Duplicated Wazuh server node names."
            exit 1
        fi

        unique_ips=($(echo "${server_node_ips[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        if [ "${#unique_ips[@]}" -ne "${#server_node_ips[@]}" ]; then 
            common_logger -e "Duplicated Wazuh server node ips."
            exit 1
        fi

        unique_names=($(echo "${dashboard_node_names[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        if [ "${#unique_names[@]}" -ne "${#dashboard_node_names[@]}" ]; then
            common_logger -e "Duplicated dashboard node names."
            exit 1
        fi

        unique_ips=($(echo "${dashboard_node_ips[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        if [ "${#unique_ips[@]}" -ne "${#dashboard_node_ips[@]}" ]; then
            common_logger -e "Duplicated dashboard node ips."
            exit 1
        fi

        if [ "${#server_node_names[@]}" -ne "${#server_node_ips[@]}" ]; then 
            common_logger -e "Different number of Wazuh server node names and IPs."
            exit 1
        fi

        for i in "${server_node_types[@]}"; do
            if ! echo "$i" | grep -ioq master && ! echo "$i" | grep -ioq worker; then
                common_logger -e "Incorrect node_type $i must be master or worker"
                exit 1
            fi
        done

        if [ "${#server_node_names[@]}" -le 1 ]; then
            if [ "${#server_node_types[@]}" -ne 0 ]; then
                common_logger -e "The tag node_type can only be used with more than one Wazuh server."
                exit 1
            fi
        elif [ "${#server_node_names[@]}" -gt "${#server_node_types[@]}" ]; then
            common_logger -e "The tag node_type needs to be specified for all Wazuh server nodes."
            exit 1
        elif [ "${#server_node_names[@]}" -lt "${#server_node_types[@]}" ]; then
            common_logger -e "Found extra node_type tags."
            exit 1
        elif [ "$(grep -io master <<< "${server_node_types[*]}" | wc -l)" -ne 1 ]; then
            common_logger -e "Wazuh cluster needs a single master node."
            exit 1
        elif [ "$(grep -io worker <<< "${server_node_types[*]}" | wc -l)" -ne $(( ${#server_node_types[@]} - 1 )) ]; then
            common_logger -e "Incorrect number of workers."
            exit 1
        fi

        if [ "${#dashboard_node_names[@]}" -ne "${#dashboard_node_ips[@]}" ]; then
            common_logger -e "Different number of dashboard node names and IPs."
            exit 1
        fi

    else
        common_logger -e "No configuration file found."
        exit 1
    fi

}
function cert_setpermisions() {
    eval "chmod -R 744 ${cert_tmp_path} ${debug}"
}
function cert_convertCRLFtoLF() {
    if [[ ! -d "/tmp/wazuh-install-files" ]]; then
        mkdir "/tmp/wazuh-install-files"
    fi
    eval "chmod -R 755 /tmp/wazuh-install-files ${debug}"
    eval "tr -d '\015' < '$1' > /tmp/wazuh-install-files/new_config.yml"
    eval "mv /tmp/wazuh-install-files/new_config.yml '$1'"
}

# ------------ certMain.sh ------------ 
function getHelp() {

    echo -e ""
    echo -e "NAME"
    echo -e "        wazuh-cert-tool.sh - Manages the creation of certificates of the Wazuh components."
    echo -e ""
    echo -e "SYNOPSIS"
    echo -e "        wazuh-cert-tool.sh [OPTIONS]"
    echo -e ""
    echo -e "DESCRIPTION"
    echo -e "        -a,  --admin-certificates </path/to/root-ca.pem> </path/to/root-ca.key>"
    echo -e "                Creates the admin certificates, add root-ca.pem and root-ca.key."
    echo -e ""
    echo -e "        -A, --all </path/to/root-ca.pem> </path/to/root-ca.key>"
    echo -e "                Creates Wazuh server, Wazuh indexer, Wazuh dashboard, and admin certificates. Add a root-ca.pem and root-ca.key or leave it empty so a new one will be created."
    echo -e ""
    echo -e "        -ca, --root-ca-certificates"
    echo -e "                Creates the root-ca certificates."
    echo -e ""
    echo -e "        -v,  --verbose"
    echo -e "                Enables verbose mode."
    echo -e ""
    echo -e "        -wd,  --wazuh-dashboard-certificates </path/to/root-ca.pem> </path/to/root-ca.key>"
    echo -e "                Creates the Wazuh dashboard certificates, add root-ca.pem and root-ca.key."
    echo -e ""
    echo -e "        -wi,  --wazuh-indexer-certificates </path/to/root-ca.pem> </path/to/root-ca.key>"
    echo -e "                Creates the Wazuh indexer certificates, add root-ca.pem and root-ca.key."
    echo -e ""
    echo -e "        -ws,  --wazuh-server-certificates </path/to/root-ca.pem> </path/to/root-ca.key>"
    echo -e "                Creates the Wazuh server certificates, add root-ca.pem and root-ca.key."
    echo -e ""
    echo -e "        -tmp,  --cert_tmp_path </path/to/tmp_dir>"
    echo -e "                Modifies the default tmp directory (/tmp/wazuh-ceritificates) to the specified one."
    echo -e "                Must be used along with one of these options: -a, -A, -ca, -wi, -wd, -ws"
    echo -e ""

    exit 1

}
function main() {

    umask 177

    cert_checkOpenSSL

    if [ -n "${1}" ]; then
        while [ -n "${1}" ]
        do
            case "${1}" in
            "-a"|"--admin-certificates")
                if [[ -z "${2}" || -z "${3}" ]]; then
                    common_logger -e "Error on arguments. Probably missing </path/to/root-ca.pem> </path/to/root-ca.key> after -a|--admin-certificates"
                    getHelp
                    exit 1
                else
                    cadmin=1
                    rootca="${2}"
                    rootcakey="${3}"
                    shift 3
                fi
                ;;
            "-A"|"--all")
                if  [[ -n "${2}" && "${2}" != "-v" && "${2}" != "-tmp" ]]; then
                    # Validate that the user has entered the 2 files
                    if [[ -z ${3} ]]; then
                        if [[ ${2} == *".key" ]]; then
                            common_logger -e "You have not entered a root-ca.pem"
                            exit 1
                        else
                            common_logger -e "You have not entered a root-ca.key" 
                            exit 1
                        fi
                    fi
                    all=1
                    rootca="${2}"
                    rootcakey="${3}"
                    shift 3
                else
                    all=1
                    shift 1
                fi
                ;;
            "-ca"|"--root-ca-certificate")
                ca=1
                shift 1
                ;;
            "-h"|"--help")
                getHelp
                ;;
            "-v"|"--verbose")
                debugEnabled=1
                shift 1
                ;;
            "-wd"|"--wazuh-dashboard-certificates")
                if [[ -z "${2}" || -z "${3}" ]]; then
                    common_logger -e "Error on arguments. Probably missing </path/to/root-ca.pem> </path/to/root-ca.key> after -wd|--wazuh-dashboard-certificates"
                    getHelp
                    exit 1
                else
                    cdashboard=1
                    rootca="${2}"
                    rootcakey="${3}"
                    shift 3
                fi
                ;;
            "-wi"|"--wazuh-indexer-certificates")
                if [[ -z "${2}" || -z "${3}" ]]; then
                    common_logger -e "Error on arguments. Probably missing </path/to/root-ca.pem> </path/to/root-ca.key> after -wi|--wazuh-indexer-certificates"
                    getHelp
                    exit 1
                else
                    cindexer=1
                    rootca="${2}"
                    rootcakey="${3}"
                    shift 3
                fi
                ;;
            "-ws"|"--wazuh-server-certificates")
                if [[ -z "${2}" || -z "${3}" ]]; then
                    common_logger -e "Error on arguments. Probably missing </path/to/root-ca.pem> </path/to/root-ca.key> after -ws|--wazuh-server-certificates"
                    getHelp
                    exit 1
                else
                    cserver=1
                    rootca="${2}"
                    rootcakey="${3}"
                    shift 3
                fi
                ;;
            "-tmp"|"--cert_tmp_path")
                if [[ -n "${3}" || ( "${cadmin}" == 1 || "${all}" == 1 || "${ca}" == 1 || "${cdashboard}" == 1 || "${cindexer}" == 1 || "${cserver}" == 1 ) ]]; then
                    if [[ -z "${2}" || ! "${2}" == /* ]]; then
                        common_logger -e "Error on arguments. Probably missing </path/to/tmp_dir> or path does not start with '/'."
                        getHelp
                        exit 1
                    else
                        cert_tmp_path="${2}"
                        shift 2
                    fi
                else
                    common_logger -e "Error: -tmp must be used along with one of these options: -a, -A, -ca, -wi, -wd, -ws"
                    getHelp
                    exit 1
                fi
                ;;
            *)
                echo "Unknow option: ${1}"
                getHelp
            esac
        done

        if [[ -d "${base_path}"/wazuh-certificates ]]; then
            if [ -n "$(ls -A "${base_path}"/wazuh-certificates)" ]; then
                common_logger -e "Directory wazuh-certificates already exists in the same path as the script. Please, remove the certs directory to create new certificates."
                exit 1
            fi
        fi
        
        if [[ ! -d "${cert_tmp_path}" ]]; then
            mkdir -p "${cert_tmp_path}"
            chmod 744 "${cert_tmp_path}"
        fi

        cert_readConfig

        if [ -n "${debugEnabled}" ]; then
            debug="2>&1 | tee -a ${logfile}"
        fi

        if [[ -n "${cadmin}" ]]; then
            cert_checkRootCA
            cert_generateAdmincertificate
            common_logger "Admin certificates created."
            cert_cleanFiles
            cert_setpermisions
            eval "mv ${cert_tmp_path} '${base_path}/wazuh-certificates' ${debug}"
        fi

        if [[ -n "${all}" ]]; then
            cert_checkRootCA
            cert_generateAdmincertificate
            common_logger "Admin certificates created."
            if cert_generateIndexercertificates; then
                common_logger "Wazuh indexer certificates created."
            fi
            if cert_generateFilebeatcertificates; then
                common_logger "Wazuh server certificates created."
            fi
            if cert_generateDashboardcertificates; then
                common_logger "Wazuh dashboard certificates created."
            fi
            cert_cleanFiles
            cert_setpermisions
            eval "mv ${cert_tmp_path} '${base_path}/wazuh-certificates' ${debug}"
        fi

        if [[ -n "${ca}" ]]; then
            cert_generateRootCAcertificate
            common_logger "Authority certificates created."
            cert_cleanFiles
            eval "mv ${cert_tmp_path} '${base_path}/wazuh-certificates' ${debug}"
        fi

        if [[ -n "${cindexer}" ]]; then
            cert_checkRootCA
            cert_generateIndexercertificates
            common_logger "Wazuh indexer certificates created."
            cert_cleanFiles
            cert_setpermisions
            eval "mv ${cert_tmp_path} '${base_path}/wazuh-certificates' ${debug}"
        fi

        if [[ -n "${cserver}" ]]; then
            cert_checkRootCA
            cert_generateFilebeatcertificates
            common_logger "Wazuh server certificates created."
            cert_cleanFiles
            cert_setpermisions
            eval "mv ${cert_tmp_path} '${base_path}/wazuh-certificates' ${debug}"
        fi

        if [[ -n "${cdashboard}" ]]; then
            cert_checkRootCA
            cert_generateDashboardcertificates
            common_logger "Wazuh dashboard certificates created."
            cert_cleanFiles
            cert_setpermisions
            eval "mv ${cert_tmp_path} '${base_path}/wazuh-certificates' ${debug}"
        fi

    else
        getHelp
    fi

}
# ------------ certVariables.sh ------------ 

function common_logger() {

    now=$(date +'%d/%m/%Y %H:%M:%S')
    mtype="INFO:"
    debugLogger=
    nolog=
    if [ -n "${1}" ]; then
        while [ -n "${1}" ]; do
            case ${1} in
                "-e")
                    mtype="ERROR:"
                    shift 1
                    ;;
                "-w")
                    mtype="WARNING:"
                    shift 1
                    ;;
                "-d")
                    debugLogger=1
                    mtype="DEBUG:"
                    shift 1
                    ;;
                "-nl")
                    nolog=1
                    shift 1
                    ;;
                *)
                    message="${1}"
                    shift 1
                    ;;
            esac
        done
    fi

    if [ -z "${debugLogger}" ] || { [ -n "${debugLogger}" ] && [ -n "${debugEnabled}" ]; }; then
        if [ "$EUID" -eq 0 ] && [ -z "${nolog}" ]; then
            printf "%s\n" "${now} ${mtype} ${message}" | tee -a "${logfile}"
        else
            printf "%b\n" "${now} ${mtype} ${message}"
        fi
    fi

}
function common_checkWazuhConfigYaml() {

    filecorrect=$(cert_parseYaml "${config_file}" | grep -Ev '^#|^\s*$' | grep -Pzc "\A(\s*(nodes_indexer__name|nodes_indexer__ip|nodes_server__name|nodes_server__ip|nodes_server__node_type|nodes_dashboard__name|nodes_dashboard__ip)=.*?)+\Z")
    if [[ "${filecorrect}" -ne 1 ]]; then
        common_logger -e "The configuration file ${config_file} does not have a correct format."
        exit 1
    fi

}

main "$@"
