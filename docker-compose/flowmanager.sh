#!/bin/bash
set -uoe pipefail

# Import common things
for i in ../scripts/common/*;
  do source $i
done

# Setup and run the app.
# Example: ./flowmanager.sh [setup/start/stop/status/help]

PROJECT_NAME="flowmanager"

function gen_config() {
    # Generate certifications
    cd ../scripts/
    ./generate_certs.sh
    cd -

    # Copy generated certificates in FM configs space
    info_message "INFO:: Copy certs in configs space..."

    cp ../scripts/custom-ca/governance/cacert.p12 ./files/$PROJECT_NAME/configs/governanceca.p12
    cp ../scripts/custom-ca/business/cacert.p12 ./files/$PROJECT_NAME/configs/businessca.p12
    cp ../scripts/custom-ca/governance/uicert.p12 ./files/$PROJECT_NAME/configs/uicert.p12

    # Create .env file
    if [ ! -f .env ]; then
        cp env.template .env
    fi
    # List config files
    if [ $? -eq 0 ]; then
        info_message "INFO:: Certificates generated and copied to the configs space"
    else
        error_message "ERROR:: Some issues in generating and copy certs to the configs space"
        exit 1
    fi
}

function start_container() {
    # Start the container(s)
    docker-compose up -d
}

function status_container() {
    # Check the container(s)
    docker-compose ps
}

function stop_container() {
    # Stop the container(s)
    docker-compose stop
}

function usage() {
    echo "--------"
    echo " HELP"
    echo "--------"
    echo "Usage: ./flowmanager.sh [option]"
    echo "  options:"
    echo "    setup  : Generate certs and create .env file"
    echo "    start  : Start the contianer(s)"
    echo "    stop   : Stop the container(s)"
    echo "    status : Show the status of the container(s)"
    echo "    help   : Show the usage of the script file"
    echo ""
    exit
}

[[ $# -eq 0 ]] && usage

if [[ $@ ]]; then
    while (( $# ))
    do
        case "$1" in
            setup)
                gen_config
                shift
                ;;
            start)
                start_container
                shift
                ;;
            stop)
                stop_container
                shift
                ;;
            status)
                status_container
                shift
                ;;
            help)
                usage
                exit 0
                ;;
            *)
                error_message "ERROR:: Command not supported. Type help option for more information"
                exit 0
                ;;
        esac
    done
else
    usage
    exit 0
fi
