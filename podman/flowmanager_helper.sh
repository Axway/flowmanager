#!/bin/bash
set -euo pipefail

# Setup and run the app.
# Example: ./flowmanager_helper.sh [setup/start/restart/stop/help...]

PROJECT_NAME="flowmanager"

# Generate and copy generated certificates in the right configs path
function gen_config() {
    # Generate certifications
    cd ../scripts/
    ./generate_certs.sh
    cd -
	
	cp ../scripts/custom-ca/governance/cacert.p12 ./files/$PROJECT_NAME/configs/governanceca.p12
    cp ../scripts/custom-ca/governance/uicert.p12 ./files/$PROJECT_NAME/configs/uicert.p12
    cp ../scripts/custom-ca/governance/governanceca.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-ca.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem ./files/st-fm-plugin/
    cp ../scripts/custom-ca/st-fm-plugin/*key ./files/st-fm-plugin/
	
	chmod 744 ./files/$PROJECT_NAME/configs/governanceca.p12
	chmod 744 ./files/$PROJECT_NAME/configs/uicert.p12
	chmod 744 -R ./files/st-fm-plugin/

    # List config files
    if [ $? -eq 0 ]; then
        echo "INFO: Certificates generated and copied to the configs space"
    else
        echo "ERROR: Some issues in generating and copy certs to the configs space"
        exit 1
    fi
}

# Start the container(s)
function start_container() {

podman play kube ./flowmanager.yml
echo "FlowManager was installed."

}

# Restart the container(s)
function update_container() {

podman pod rm -f flowmanager_pod
podman play kube ./flowmanager.yml
echo "Pod 'flowmanager_pod' was updated"

}

# Check the container(s)
function status_container() {
podman pod stats flowmanager_pod
}

# Stop the container(s)
function stop_container() {
podman pod stop flowmanager_pod
echo "Pod 'flowmanager_pod' was stopped"
}

# Delete the container(s)
function delete_container() {
podman pod rm -f flowmanager_pod
rm -rf ./mongodb_data_container/*
echo "Pod 'flowmanager_pod' was deleted"
}

# Restart the container(s)
function inspect() {
podman pod inspect flowmanager_pod
}

# How to use the script
function usage() {
    echo "--------"
    echo " HELP"
    echo "--------"
    echo "Usage: ./$PROJECT_NAME [option]"
    echo "  options:"
    echo "    setup    : Generate certificates"
    echo "    start    : Start $PROJECT_NAME and database containers"
    echo "    update   : Update $PROJECT_NAME and database containers with new configuration"
    echo "    stop     : Stop $PROJECT_NAME and database containers"
    echo "    stats    : Show the status of $PROJECT_NAME and database containers"
    echo "    delete   : Delete $PROJECT_NAME, database containers and other parts related to the containers, like storage"
    echo "    inspect  : Get the details about your flowmanager pod"
    echo "    help     : Show the usage of the script file"
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
            update)
                if [ -z "${2-}" ]; then
                    update_container
                else
                    update_container $2
                fi
                shift
                ;;
            stats)
                status_container
                shift
                ;;
            delete)
                delete_container
                shift
                ;;
            inspect)
                if [ -z "${2-}" ]; then
                    inspect
                else
                    inspect $2
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
