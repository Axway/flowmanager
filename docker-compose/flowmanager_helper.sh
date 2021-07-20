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
    # Generate certifications
    cd ../scripts/
    ./generate_certs.sh
    cd -

    # Copy generated certificates in FM configs space
    info_message "INFO: Copy certs in configs space..."

    cp ../scripts/custom-ca/governance/cacert.p12 ./files/$PROJECT_NAME/configs/governanceca.p12
    cp ../scripts/custom-ca/business/cacert.p12 ./files/$PROJECT_NAME/configs/businessca.p12
    cp ../scripts/custom-ca/governance/uicert.p12 ./files/$PROJECT_NAME/configs/uicert.p12
    cp ../scripts/custom-ca/governance/governanceca.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-ca.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/*key ./files/st-fm-plugin/

    # Create .env file
    if [ ! -f .env ]; then
        cp env.template .env
    fi
    # List config files
    if [ $? -eq 0 ]; then
        info_message "INFO: Certificates generated and copied to the configs space"
    else
        error_message "ERROR: Some issues in generating and copy certs to the configs space"
        exit 1
    fi
}

# Start the container(s)
function start_container() {
    local name=${1-}
    if [ ! -f .env ]; then
        echo "There is not .env file. Please create it by running this command: ./flowmanager_helper.sh setup"
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

# Check the container(s)
function status_container() {
    docker-compose ps
}

# Stop the container(s)
function stop_container() {
    docker-compose stop
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
    echo "    setup  : Generate certs and create .env file"
    echo "    start  : Start $PROJECT_NAME and database containers"
    echo "    restart: Restart $PROJECT_NAME and database containers"
    echo "    stop   : Stop $PROJECT_NAME and database containers"
    echo "    status : Show the status of $PROJECT_NAME and database containers"
    echo "    delete : Delete $PROJECT_NAME, database containers and other parts related to the containers, like storage"
    echo "    logs   : Get logs for $PROJECT_NAME and database"
    echo "    help   : Show the usage of the script file"
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
                stop_container
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
                error_message "ERROR: Invalid option $1. Type help option for more information"
                exit 0
                ;;
        esac
    done
else
    usage
    exit 0
fi
