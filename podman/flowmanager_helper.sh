#!/bin/bash
set -euo pipefail

# Import common things

for i in ../scripts/common/*; do
    source "$i"
done

# Setup and run the app.
# Example: ./flowmanager_helper.sh [setup/start/restart/stop/status/help...]

PUBLIC_GOV_CA_FILE="../scripts/custom-ca/governance/cacert.pem"

function generate_and_copy_govca() {
    local CERT_PASS=$1
    local CERT_EXPIRATION_DAYS=$2

    info_message "INFO: Generating Governance CA..."

    cd ../scripts
    ./generate_certs.sh --generate-governance-ca "$CERT_PASS" "$CERT_EXPIRATION_DAYS" "$CERT_PASS"
    cd - >/dev/null

    if [ -f ./files/flowmanager/configs/governanceca.pem ]; then
        OLD_GOV_CA_PASSWORD=$(awk '/^        - name: FM_GOVERNANCE_CA_PASSWORD/{getline; sub(/^          value:[ ]*/, "", $0); gsub(/"/, "", $0); print $0}' flowmanager.yml)
        sed -i "/^        - name: FM_OLD_GOV_CA_PASSWORD/{n;s|^          value:.*|          value: \"$OLD_GOV_CA_PASSWORD\"|;}" flowmanager.yml
        sed -i "/^        - name: FM_OLD_GOV_CA_FILE/{n;s|^          value:.*|          value: \"/opt/axway/FlowManager/configs/governanceca-old.pem\"|;}" flowmanager.yml

        mv ./files/flowmanager/configs/governanceca.pem ./files/flowmanager/configs/governanceca-old.pem
        mv ./files/st-fm-plugin/governanceca.pem ./files/st-fm-plugin/governanceca-old.pem
        mv ./files/monitoring-fm-plugin/governanceca.pem ./files/monitoring-fm-plugin/governanceca-old.pem
    fi

    cp ../scripts/custom-ca/governance/governanceca.pem ./files/flowmanager/configs/
    sed -i "/^        - name: FM_GOVERNANCE_CA_PASSWORD/{n;s|^          value:.*|          value: \"$PASSWORD\"|;}" flowmanager.yml

    cp "$PUBLIC_GOV_CA_FILE" ./files/st-fm-plugin/governanceca.pem
    cp "$PUBLIC_GOV_CA_FILE" ./files/monitoring-fm-plugin/governanceca.pem

    info_message "INFO: Governance CA was generated and copied successfully."
}

function generate_and_copy_plugin_certs() {
    local PLUGIN_NAME=$1
    local CERT_PASS=$2
    local CERT_EXPIRATION_DAYS=$3

    info_message "INFO: Generating $PLUGIN_NAME certificates..."

    cd ../scripts/
    ./generate_certs.sh "--generate-$PLUGIN_NAME-certs" "$CERT_PASS" "$CERT_EXPIRATION_DAYS" "$CERT_PASS"
    cd - >/dev/null

    cp "../scripts/custom-ca/$PLUGIN_NAME/$PLUGIN_NAME"* "./files/$PLUGIN_NAME/"
    rm -rf "./files/$PLUGIN_NAME/$PLUGIN_NAME-cert-csr.pem" || true
    create_plugin_cert_private_key_password_file "$PLUGIN_NAME" "$CERT_PASS"

    info_message "INFO: $PLUGIN_NAME certificates were generated and copied successfully."
}

function generate_and_copy_plugin_keys() {
    local PLUGIN_NAME=$1
    local CERT_PASS=$2
    local CERT_EXPIRATION_DAYS=$3

    info_message "INFO: Generating $PLUGIN_NAME keys..."

    cd ../scripts/
    ./generate_certs.sh "--generate-$PLUGIN_NAME-keys" "$CERT_PASS" "$CERT_EXPIRATION_DAYS" "$CERT_PASS"
    cd - >/dev/null

    cp "../scripts/custom-ca/$PLUGIN_NAME-keys/$PLUGIN_NAME"* "./files/$PLUGIN_NAME/"

    info_message "INFO: $PLUGIN_NAME keys were generated and copied successfully."
}

function create_plugin_cert_private_key_password_file() {
    local PLUGIN_NAME=$1
    local CERT_PASS=$2

    echo "$CERT_PASS" >"./files/$PLUGIN_NAME/$PLUGIN_NAME-private-key-password.txt"
}

function generate_and_copy_everything() {
    local CERT_PASS=$1
    local CERT_EXPIRATION_DAYS=$2

    # Generate certificates
    generate_and_copy_govca "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_certs st-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_keys st-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_certs monitoring-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_keys monitoring-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"

    cd ../scripts
    info_message "INFO: Generating Business CA..."
    ./generate_certs.sh --generate-business-ca "$CERT_PASS" "$CERT_EXPIRATION_DAYS" "$CERT_PASS"
    info_message "INFO: Generating FM Core Keys..."
    ./generate_certs.sh --generate-fm-core-keys "$CERT_PASS" "$CERT_EXPIRATION_DAYS" "$CERT_PASS"
    cd - >>/dev/null

    info_message "INFO: Copying FM certificates in configs folder..."

    cp ../scripts/custom-ca/governance/governanceca.pem ./files/flowmanager/configs/
    cp ../scripts/custom-ca/business/businessca.p12 ./files/flowmanager/configs/
    cp ../scripts/custom-ca/fm-core-keys/fm-core-jwt-key.pem ./files/flowmanager/configs/

    create_plugin_cert_private_key_password_file st-fm-plugin "$PASSWORD"
    create_plugin_cert_private_key_password_file monitoring-fm-plugin "$PASSWORD"

    # List config files
    info_message "INFO: Operation was successful."
}

# Start the container(s)
function start_container() {
    podman play kube ./flowmanager.yml
    echo "FlowManager was installed."
}

# Restart the container(s)
function restart_container() {
    podman pod rm -f flowmanager_pod
    podman play kube ./flowmanager.yml
    echo "Flow Manager was restarted"
}

# Check the container(s)
function status_container() {
    podman pod stats flowmanager_pod
}

# Stop the container(s)
function stop_container() {
    podman pod rm -f flowmanager_pod
    echo "Flow Manager was stopped"
}

# Delete the container(s) + mongo data
function delete_container() {
    podman pod rm -f flowmanager_pod
    rm -rf ./mongodb_data_container/*
    echo "Flow Manager was stopped and MongoDB's content was deleted"
}

# logs
function log_container() {
    podman pod logs flowmanager_pod
}

# How to use the script
function usage() {
    echo "--------"
    echo " HELP"
    echo "--------"
    echo "Usage: ./flowmanager_helper.sh [options...]"
    echo "Options:"
    echo "  Certificate generation:"
    echo "    setup                                                                                         interactive certificate generation"
    echo "    setup --non-interactive [arguments...] <CERTIFICATE_ENCRYPTION_PASSWORD> <EXPIRATION_DAYS>    non-interactive certificate generation"
    echo "                                                                                                  <CERTIFICATE_ENCRYPTION_PASSWORD> is the password of the private key of the certificate"
    echo "                                                                                                  <EXPIRATION_DAYS> is the number of days for which the certificate is valid"        
    echo "      Arguments:"
    echo "        --generate-everything                                  generates all certificates and keys for Flow Manager, ST Plugin, Monitoring Plugin"
    echo "        --st-fm-plugin-certs-and-keys,          --st-all       generates certificates and keys for ST Plugin"
    echo "        --st-fm-plugin-certs,                   --st-certs     generates only the certificates for ST Plugin"
    echo "        --monitoring-fm-plugin-certs-and-keys,  --mon-all      generates certificates and keys for Monitoring Plugin"
    echo "        --monitoring-fm-plugin-certs,           --mon-certs    generates only the certificates for Monitoring Plugin"
    echo "        --governance-ca,                        --gov-ca       re/generates only the Governance CA, distributes it to all plugins" 
    echo ""
    echo "    Example: ./flowmanager_helper.sh setup --non-interactive --generate-everything password 365"
    echo ""                                                           
    echo "    It is recommended to backup your certificates before generating new ones."
    echo "    Please note that renewing governance CA impacts managed products. See Flow Manager User Guide and Security Guide for more info."
    echo ""
    echo "  Container management:"
    echo "    start  : Starts all containers."
    echo "    restart: Restarts all containers."
    echo "    stop   : Stops all containers."
    echo "    status : Shows the status of all containers."
    echo "    delete : Deletes all containers (including database!) and the MongoDB storage."
    echo "    logs   : Gets logs from all containers."
    echo ""
    echo "  Help:"
    echo "    help   : Shows the usage of this script."
    echo ""
}

function interactive_menu() {
    echo "Welcome to the FM certificate generation wizard. How do you wish to proceed?"

    echo "1. Generate everything"
    echo "2. Generate ST FM Plugin certificates and keys"
    echo "3. Generate ST FM Plugin certificates"
    echo "4. Generate Monitoring FM Plugin certificates and keys"
    echo "5. Generate Monitoring FM Plugin certificates"
    echo "6. Generate Governance CA"
    echo "7. Exit"
    read -rp "Enter your choice [1-7]: " choice

    case "$choice" in
    7)
        echo "Exiting."
        exit 0
        ;;
    *)
        if ! [[ "$choice" =~ ^[1-6]$ ]]; then
            echo "ERROR: Invalid choice. Exiting."
            exit 1
        fi
        ;;
    esac

    # Prompt for password and expiration days
    PASSWORD="abc"
    SECOND_PASSWORD="def"
    while [ "$PASSWORD" != "$SECOND_PASSWORD" ]; do
        echo "Please choose a password for the certificates:"
        read -rs PASSWORD
        echo "******"
        echo "Type the password again:"
        read -rs SECOND_PASSWORD
        echo "******"
        if [ "$PASSWORD" != "$SECOND_PASSWORD" ]; then
            echo
            echo "The passwords do not match!"
            echo
        fi
    done
    echo "Set EXPIRATION_DAYS for the certificates: "
    read -r EXPIRATION_DAYS

    case "$choice" in
    1)
        generate_and_copy_everything "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    2)
        generate_and_copy_plugin_certs st-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        generate_and_copy_plugin_keys st-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    3)
        generate_and_copy_plugin_certs st-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    4)
        generate_and_copy_plugin_certs monitoring-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        generate_and_copy_plugin_keys monitoring-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    5)
        generate_and_copy_plugin_certs monitoring-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    6)
        echo "It is recommended to backup your certificates before proceeding. Please note that renewing governance CA impacts managed products. See Flow Manager User Guide and Security Guide for more info."
        echo "Do you wish to continue? [y/n]"
        read -r response
        case "$response" in
        yes | y)
            generate_and_copy_govca "$PASSWORD" "$EXPIRATION_DAYS"
            ;;
        no | n)
            echo "Operation cancelled."
            ;;
        *)
            echo "ERROR: Invalid response. Operation cancelled."
            exit 1
            ;;
        esac
        ;;
    esac
}

function non_interactive() {
    echo "Non-interactive setup."

    if [[ -n "${2-}" && -n "${3-}" ]]; then
        local PASSWORD=$2
        local EXPIRATION_DAYS=$3
    else
        echo "ERROR: Missing required arguments for non-interactive setup."
        exit 1
    fi
    case "$1" in
    --generate-everything)
        generate_and_copy_everything "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    --st-fm-plugin-certs-and-keys | --st-all)
        generate_and_copy_plugin_certs st-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        generate_and_copy_plugin_keys st-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    --st-fm-plugin-certs | --st-certs)
        generate_and_copy_plugin_certs st-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    --monitoring-fm-plugin-certs-and-keys | --mon-all)
        generate_and_copy_plugin_certs monitoring-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        generate_and_copy_plugin_keys monitoring-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    --monitoring-fm-plugin-certs | --mon-certs)
        generate_and_copy_plugin_certs monitoring-fm-plugin "$PASSWORD" "$EXPIRATION_DAYS"
        ;;
    --governance-ca | --gov-ca)
        echo "It is recommended to backup your certificates before proceeding. Please note that renewing governance CA impacts managed products. See Flow Manager User Guide and Security Guide for more info."
        echo "Do you wish to continue? [y/n]"
        read -r response
        case "$response" in
        yes | y)
            generate_and_copy_govca "$PASSWORD" "$EXPIRATION_DAYS"
            ;;
        no | n)
            echo "Operation cancelled."
            ;;
        *)
            echo "ERROR: Invalid response. Operation cancelled."
            exit 1
            ;;
        esac
        ;;

    esac
}

if [[ $* ]]; then
    case "$1" in
    setup)
        shift
        if [[ $# -eq 0 ]]; then
            interactive_menu
        else
            if [[ "$1" == "--non-interactive" ]]; then
                shift
                non_interactive "$@"
            else
                echo "ERROR: Invalid option. Please use the correct flag after setup."
                exit 1
            fi
        fi
        chmod -R 755 ./files
        ;;
    start)
        if [ -z "${2-}" ]; then
            start_container
        else
            start_container "$2"
        fi
        ;;
    stop)
        if [ -z "${2-}" ]; then
            stop_container
        else
            stop_container "$2"
        fi
        ;;
    restart)
        if [ -z "${2-}" ]; then
            restart_container
        else
            restart_container "$2"
        fi
        ;;
    status)
        status_container
        ;;
    delete)
        delete_container
        ;;
    logs)
        if [ -z "${2-}" ]; then
            log_container
        else
            log_container "$2"
        fi
        ;;
    help)
        usage
        ;;
    *)
        error_message "ERROR: Invalid option $1. Type help option for more information."
        ;;
    esac
else
    usage
fi