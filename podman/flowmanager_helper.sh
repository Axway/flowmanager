#!/bin/bash
set -euo pipefail

# Import common things
for i in ../scripts/common/*;
  do source $i
done

# Setup and run the app.
# Example: ./flowmanager_helper.sh [setup/start/restart/stop/help...]

PROJECT_NAME="flowmanager"
GOV_CA_FILE="../scripts/custom-ca/governance/cacert.pem"
MON_FM_PLUGIN_NAME="monitoring-fm-plugin"
ST_FM_PLUGIN_NAME="st-fm-plugin"

function copy_config_generic_plugin() {
  local plugin_name=$1
  info_message "INFO: Copying $plugin_name certificates..."
  if [[ -f "$GOV_CA_FILE" ]]; then
    cp "$GOV_CA_FILE" ./files/"$plugin_name"/governanceca.pem
  fi
  cp ../scripts/custom-ca/"$plugin_name"/"$plugin_name"-ca.pem ./files/"$plugin_name"/
  cp ../scripts/custom-ca/"$plugin_name"/"$plugin_name"-cert.pem ./files/"$plugin_name"/
  cp ../scripts/custom-ca/"$plugin_name"/"$plugin_name"-cert-key.pem ./files/"$plugin_name"/
  cp ../scripts/custom-ca/"$plugin_name"/"$plugin_name"-private-key.pem ./files/"$plugin_name"/
  cp ../scripts/custom-ca/"$plugin_name"/"$plugin_name"-public-key.pem ./files/"$plugin_name"/
  chmod -R 755 ./files/"$plugin_name"
  info_message "INFO: $plugin_name certificates were generated and copied successfully."
}

function copy_config_st_fm_plugin() {
    # Copy generated ST-FM plugin certificates in files/st-fm-plugin
    cp ../scripts/custom-ca/$ST_FM_PLUGIN_NAME/$ST_FM_PLUGIN_NAME-shared-secret ./files/$ST_FM_PLUGIN_NAME/
    copy_config_generic_plugin $ST_FM_PLUGIN_NAME
}

function generate_config_st_fm_plugin() {
    cd ../scripts/
    source ./generate_certs.sh st-fm-plugin
    cd -

    copy_config_st_fm_plugin
}

function copy_config_monitoring_fm_plugin() {
    # Copy generated Monitoring plugin certificates in files/monitoring-fm-plugin
    copy_config_generic_plugin $MON_FM_PLUGIN_NAME
    
    info_message "INFO: $MON_FM_PLUGIN_NAME shared secret was generated and updated in the configuration."
}

function generate_config_monitoring_fm_plugin() {
    cd ../scripts/
    source ./generate_certs.sh monitoring-fm-plugin
    cd -

    copy_config_monitoring_fm_plugin
}

# Generate and copy generated certificates in the right configs path
function gen_config() {
    # Generate certificates
    cd ../scripts/
    source ./generate_certs.sh
    cd -

    # Copy generated certificates in FM configs space
    info_message "INFO: Copying FM certificates in configs folder..."

    cp ../scripts/custom-ca/governance/governanceca.pem ./files/$PROJECT_NAME/configs/
    cp ../scripts/custom-ca/business/cacert.p12 ./files/$PROJECT_NAME/configs/businessca.p12
    cp ../scripts/custom-ca/governance/uicert.pem ./files/$PROJECT_NAME/configs/

    copy_config_st_fm_plugin
    copy_config_monitoring_fm_plugin

    # List config files
    if [ $? -eq 0 ]; then
        info_message "INFO: Operation was successful."
    else
        error_message "ERROR: There was an error generating or copying the certificates."
        exit 1
    fi
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

# Delete the container(s)
function delete_container() {
    podman pod rm -f flowmanager_pod
    rm -rf ./mongodb_data_container/*
    echo "Flow Manager was stopped and MongoDB's content was deleted"
}

# logs
function get_logs()
{
    podman pod logs flowmanager_pod
}

# How to use the script
function usage() {
    echo "--------"
    echo " HELP"
    echo "--------"
    echo "Usage: ./${PROJECT_NAME}_helper.sh [option]"
    echo "  options:"
    echo "    setup  : Generates certificates and keys for Flow Manager, Monitoring-FM Plugin, ST-FM Plugin."
    echo "           [--st-fm-plugin | -st]: Generates certificates and keys for ST-FM Plugin."
    echo "           [--monitoring-fm-plugin | -mon]: Generates certificates and keys for Monitoring-FM Plugin."
    echo "    start  : Starts all containers."
    echo "    restart: Restarts all containers."
    echo "    stop   : Stops all containers."
    echo "    status : Shows the status of all containers."
    echo "    delete : Stops all containers and deletes the MongoDB database content."
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
              if [[ -z "${2-}" ]]; then
                gen_config
              fi
              shift
              while (( $# ))
              do
                case "$1" in
                --monitoring-fm-plugin | -mon)
                  generate_config_monitoring_fm_plugin
                  shift
                  ;;
                --st-fm-plugin | -st)
                  generate_config_st_fm_plugin
                  shift
                  ;;
                *)
                  error_message "ERROR: Invalid option $1. Type help option for more information."
                  exit 0
                  ;;
                esac
              done
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
            stats)
                status_container
                shift
                ;;
            delete)
                delete_container
                shift
                ;;
            logs)
                get_logs
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
