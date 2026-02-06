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
        OLD_GOV_CA_PASSWORD=$(grep -w FM_GOVERNANCE_CA_PASSWORD .env | awk -F "=" '{print $2}' | tr -d '"')
        sed -i "s/FM_OLD_GOV_CA_PASSWORD=.*/FM_OLD_GOV_CA_PASSWORD=\"$OLD_GOV_CA_PASSWORD\"/g" .env
        sed -i "s#FM_OLD_GOV_CA_FILE=.*#FM_OLD_GOV_CA_FILE=\"/opt/axway/FlowManager/configs/governanceca-old.pem\"#g" .env

        mv ./files/flowmanager/configs/governanceca.pem ./files/flowmanager/configs/governanceca-old.pem
        mv ./files/st-fm-plugin/governanceca.pem ./files/st-fm-plugin/governanceca-old.pem
        mv ./files/monitoring-fm-plugin/governanceca.pem ./files/monitoring-fm-plugin/governanceca-old.pem
        mv ./files/fm-bridge/governanceca.pem ./files/fm-bridge/governanceca-old.pem
    fi

    cp ../scripts/custom-ca/governance/governanceca.pem ./files/flowmanager/configs/
    sed -i "s/FM_GOVERNANCE_CA_PASSWORD=.*/FM_GOVERNANCE_CA_PASSWORD=\"$PASSWORD\"/g" .env

    cp "$PUBLIC_GOV_CA_FILE" ./files/st-fm-plugin/governanceca.pem
    cp "$PUBLIC_GOV_CA_FILE" ./files/monitoring-fm-plugin/governanceca.pem
    cp "$PUBLIC_GOV_CA_FILE" ./files/fm-bridge/governanceca.pem

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

function generate_fm_bridge_certs() {
    local PLUGIN_NAME=fm-bridge
    local CERT_PASS=$1
    local CERT_EXPIRATION_DAYS=$2

    GOV_CA_PASSWORD=$(grep -w FM_GOVERNANCE_CA_PASSWORD .env | awk -F "=" '{print $2}' | tr -d '"')

    info_message "INFO: Generating $PLUGIN_NAME certificates..."

    cd ../scripts/
    ./generate_certs.sh "--generate-$PLUGIN_NAME-certs" "$CERT_PASS" "$CERT_EXPIRATION_DAYS" "$GOV_CA_PASSWORD"
    cd - >/dev/null

    cp "../scripts/custom-ca/$PLUGIN_NAME/$PLUGIN_NAME"* "./files/$PLUGIN_NAME/"
    rm -rf "./files/$PLUGIN_NAME/$PLUGIN_NAME-cert-csr.pem" || true
    create_plugin_cert_private_key_password_file "$PLUGIN_NAME" "$CERT_PASS"

    info_message "INFO: $PLUGIN_NAME certificates were generated and copied successfully."
}

function create_plugin_cert_private_key_password_file() {
    local PLUGIN_NAME=$1
    local CERT_PASS=$2

    echo "$CERT_PASS" >"./files/$PLUGIN_NAME/$PLUGIN_NAME-private-key-password.txt"
}

function generate_and_copy_everything() {
    local CERT_PASS=$1
    local CERT_EXPIRATION_DAYS=$2

    # Create .env file
    if [ ! -f .env ]; then
        cp env.template .env
    fi

    # Generate certificates
    generate_and_copy_govca "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_certs st-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_keys st-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_certs monitoring-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_and_copy_plugin_keys monitoring-fm-plugin "$CERT_PASS" "$CERT_EXPIRATION_DAYS"
    generate_fm_bridge_certs "$CERT_PASS" "$CERT_EXPIRATION_DAYS" "$CERT_PASS"
    generate_and_copy_plugin_keys fm-bridge "$CERT_PASS" "$CERT_EXPIRATION_DAYS"

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
    cp ../scripts/custom-ca/fm-bridge-keys/fm-bridge-jwt-public-key.pem ./files/flowmanager/configs/

    sed -i "s/BRIDGE_KEY_PASSWORD=.*/BRIDGE_KEY_PASSWORD=\"$PASSWORD\"/g" .env

    create_plugin_cert_private_key_password_file st-fm-plugin "$PASSWORD"
    create_plugin_cert_private_key_password_file monitoring-fm-plugin "$PASSWORD"

    # List config files
    info_message "INFO: Operation was successful."
}

# Start the container(s)
function start_container() {
    local name=${1-}
    if [ ! -f .env ]; then
        echo "ERROR: There is no .env file detected. Please create it manually or by running ./flowmanager_helper.sh setup."
        exit 1
    else
        if [ -z "$name" ]; then
            docker compose up -d
        else
            docker compose up -d "$name"
        fi
    fi
}

# Restart the container(s)
function restart_container() {
    local name=${1-}
    if [ -z "$name" ]; then
        docker compose down
        docker compose up -d
    else
        docker compose down "$name"
        docker compose up -d "$name"
    fi
}

# Migrate old docker compose to env file
function migrate() {
    ../scripts/migrate.sh
}

# Check the container(s)
function status_container() {
    docker compose ps
}

# Stop the container(s)
function stop_container() {
    local name=${1-}
    if [ -z "$name" ]; then
        docker compose down
    else
        docker compose down "$name"
    fi
}

# Delete the container(s) + mongo data
function delete_container() {
    docker compose down -v
}

# logs
function log_container() {
    local name=${1-}
    if [ -z "$name" ]; then
        docker compose logs
    else
        docker compose logs "$name"
    fi
}

# Create empty password files for Flow Manager and plugins
function create_passwords_file() {
    info_message "INFO: Creating empty password files for Flow Manager and plugins..."

    # File list
    password_files=(
        "./files/flowmanager/configs/fm-governance-ca-password"
        "./files/flowmanager/configs/fm-database-user-password"
        "./files/flowmanager/configs/fm-https-keystore-password"
        "./files/flowmanager/configs/fm-user-initial-password"
        "./files/flowmanager/configs/fm-https-client-keystore-password"
        "./files/flowmanager/configs/fm-cftplugin-privatekey-password"
        "./files/flowmanager/configs/fm-core-privatekey-password"
        "./files/st-fm-plugin/st-fm-plugin-database-user-password"
        "./files/mongo/config/mongo-app-pass"
        "./files/monitoring-fm-plugin/monitoring-plugin-db-user-password"
    )

    # Create empty files
    for file_path in "${password_files[@]}"; do
        : > "$file_path"
        chmod 600 "$file_path"
        info_message "INFO: Created empty file $file_path"
    done

    info_message "INFO: All password files created successfully."
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
    echo "        --generate-everything                                  generates all certificates and keys for Flow Manager, ST Plugin, Monitoring Plugin, Bridge and creates the .env file"
    echo "        --st-fm-plugin-certs-and-keys,          --st-all       generates certificates and keys for ST Plugin"
    echo "        --st-fm-plugin-certs,                   --st-certs     generates only the certificates for ST Plugin"
    echo "        --monitoring-fm-plugin-certs-and-keys,  --mon-all      generates certificates and keys for Monitoring Plugin"
    echo "        --monitoring-fm-plugin-certs,           --mon-certs    generates only the certificates for Monitoring Plugin"
    echo "        --fm-bridge-certs-and-keys,             --br-all       generates certificates and keys for the Bridge"
    echo "        --fm-bridge-certs,                      --br-certs     generates only the certificates for the Bridge"
    echo "        --governance-ca,                        --gov-ca       re/generates only the Governance CA, distributes it to all plugins and regenerates the Bridge certificates" 
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
    echo "    migrate: Migrate old docker compose model to .env file model."
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
    echo "6. Generate Bridge certificates and keys"
    echo "7. Generate Bridge certificates"
    echo "8. Generate Governance CA"
    echo "9. Exit"
    read -rp "Enter your choice [1-9]: " choice

    case "$choice" in
    9)
        echo "Exiting."
        exit 0
        ;;
    *)
        if ! [[ "$choice" =~ ^[1-8]$ ]]; then
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
        generate_fm_bridge_certs "$PASSWORD" "$EXPIRATION_DAYS"
        generate_and_copy_plugin_keys fm-bridge "$PASSWORD" "$EXPIRATION_DAYS"
        sed -i "s/BRIDGE_KEY_PASSWORD=.*/BRIDGE_KEY_PASSWORD=\"$PASSWORD\"/g" .env
        ;;
    7)
        generate_fm_bridge_certs "$PASSWORD" "$EXPIRATION_DAYS"
        sed -i "s/BRIDGE_KEY_PASSWORD=.*/BRIDGE_KEY_PASSWORD=\"$PASSWORD\"/g" .env
        ;;
    8)
        echo "It is recommended to backup your certificates before proceeding. Please note that renewing governance CA impacts managed products. See Flow Manager User Guide and Security Guide for more info."
        echo "Do you wish to continue? [y/n]"
        read -r response
        case "$response" in
        yes | y)
            generate_and_copy_govca "$PASSWORD" "$EXPIRATION_DAYS"
            generate_and_copy_plugin_certs fm-bridge "$PASSWORD" "$EXPIRATION_DAYS"
            sed -i "s/BRIDGE_KEY_PASSWORD=.*/BRIDGE_KEY_PASSWORD=\"$PASSWORD\"/g" .env
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
    --fm-bridge-certs-and-keys | --br-all)
        generate_fm_bridge_certs "$PASSWORD" "$EXPIRATION_DAYS" 
        generate_and_copy_plugin_keys fm-bridge "$PASSWORD" "$EXPIRATION_DAYS"
        sed -i "s/BRIDGE_KEY_PASSWORD=.*/BRIDGE_KEY_PASSWORD=\"$PASSWORD\"/g" .env
        ;;
    --fm-bridge-certs | --br-certs)
        generate_fm_bridge_certs "$PASSWORD" "$EXPIRATION_DAYS"
        sed -i "s/BRIDGE_KEY_PASSWORD=.*/BRIDGE_KEY_PASSWORD=\"$PASSWORD\"/g" .env
        ;;
    --governance-ca | --gov-ca)
        echo "It is recommended to backup your certificates before proceeding. Please note that renewing governance CA impacts managed products. See Flow Manager User Guide and Security Guide for more info."
        echo "Do you wish to continue? [y/n]"
        read -r response
        case "$response" in
        yes | y)
            generate_and_copy_govca "$PASSWORD" "$EXPIRATION_DAYS"
            generate_and_copy_plugin_certs fm-bridge "$PASSWORD" "$EXPIRATION_DAYS"
            sed -i "s/BRIDGE_KEY_PASSWORD=.*/BRIDGE_KEY_PASSWORD=\"$PASSWORD\"/g" $CONFIG
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
    create-passwords-file)
            create_passwords_file
        shift
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
    migrate)
        migrate
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
