#!/bin/bash
set -euo pipefail

# Import common things
for i in ../scripts/common/*;
  do source $i
done

# Setup and run the app.
# Example: ./flowmanager_helper.sh [setup/start/restart/stop/status/help...]

PROJECT_NAME="flowmanager"

# Generate and copy generated certificates in the right configs path
function gen_config() {
    # Generate certificates
    cd ../scripts/
    ./generate_certs.sh
    cd -

    # Copy generated certificates in FM configs space
    info_message "INFO: Copying certificates in configs folder..."

    cp ../scripts/custom-ca/governance/cacert.p12 ./files/$PROJECT_NAME/configs/governanceca.p12
    cp ../scripts/custom-ca/business/cacert.p12 ./files/$PROJECT_NAME/configs/businessca.p12
    cp ../scripts/custom-ca/governance/uicert.p12 ./files/$PROJECT_NAME/configs/uicert.p12
    cp ../scripts/custom-ca/governance/governanceca.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-ca.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/*key ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-shared-secret ./files/st-fm-plugin/
    chmod -R 755 ./files/st-fm-plugin

    # Create .env file
    if [ ! -f .env ]; then
        cp env.template .env
    fi
    # List config files
    if [ $? -eq 0 ]; then
        info_message "INFO: Certificates were generated and copied successfully to configs folder."
    else
        error_message "ERROR: There was an error generating or copying the certificates."
        exit 1
    fi
}

# Start the container(s)
function start_container() {
    local name=${1-}
    if [ ! -f .env ]; then
        echo "There is no .env file detected. Please create it manually or by running ./flowmanager_helper.sh setup."
        exit 1
    else
        if [ -z "$name" ]; then
            docker-compose up -d
        else
            docker-compose up -d $name
            exit 0
        fi
    fi
}

# Restart the container(s)
function restart_container() {
    local name=${1-}
    if [ -z "$name" ]; then
        docker-compose restart
    else
        docker-compose restart $name
        exit 0;
    fi
}

# Migrate old docker compose to env file
function migrate() {
    ../scripts/migrate.sh
}

# Check the container(s)
function status_container() {
    docker-compose ps
}

# Stop the container(s)
function stop_container() {
    local name=${1-}
    if [ -z "$name" ]; then
        docker-compose stop
    else
        docker-compose stop $name
        exit 0;
    fi
    
}

# Delete the container(s)
function delete_container() {
    docker-compose down -v
}

# Restart the container(s)
function log_container() {
    local name=${1-}
    if [ -z "$name" ]; then
        docker-compose logs
    else
        docker-compose logs $name
        exit 0;
    fi
}

# How to use the script
function usage() {
    echo "--------"
    echo " HELP"
    echo "--------"
    echo "Usage: ./$PROJECT_NAME [option]"
    echo "  options:"
    echo "    setup  : Generates certificates and creates the .env file."
    echo "    start  : Starts all containers."
    echo "    restart: Restarts all containers."
    echo "    stop   : Stops all containers."
    echo "    status : Shows the status of all containers."
    echo "    migrate: Migrate old docker compose model to .env file model."
    echo "    delete : Deletes all containers (including database!) and other parts related to the containers, like storage."
    echo "    logs   : Gets logs from all containers."
    echo "    help   : Shows the usage of this script."
    echo ""
    exit
}

[[ $# -eq 0 ]] && usage

# Menu
if [[ $@ ]]; then
    while (( $# ))
    do
        case "$1" in
            setup)
                gen_config
                shift
                ;;
            start)
                if [ -z "${2-}" ]; then
                    start_container
                else
                    start_container $2
                fi
                shift
                ;;
            stop)
                if [ -z "${2-}" ]; then
                    stop_container
                else
                    stop_container $2
                fi
                shift
                ;;
            restart)
                if [ -z "${2-}" ]; then
                    restart_container
                else
                    restart_container $2
                fi
                shift
                ;;
            migrate)
                migrate
                shift
                ;;
            status)
                status_container
                shift
                ;;
            delete)                
                delete_container
                shift
                ;;
            logs)
                if [ -z "${2-}" ]; then
                    log_container
                else
                    log_container $2
                fi
                shift
                ;;
            help)
                usage
                exit 0
                ;;
            *)
                error_message "ERROR: Invalid option $1. Type help option for more information."
                exit 0
                ;;
        esac
    done
else
    usage
    exit 0
fi
