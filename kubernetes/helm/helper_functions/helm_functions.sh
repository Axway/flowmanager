#!/bin/bash
# set -x
###########################################
# startup function
###########################################
function namespace_choice(){
  echo "Please gives your namespace:" 
  read -r NAMESPACE 
  export NAMESPACE=${NAMESPACE}
  if kubectl get namespace ${NAMESPACE} | grep -q 'Active'
  then
    msg_info "The namespace ${NAMESPACE} exists"
  else
    msg_info "The namespace ${NAMESPACE} does not exist. Do you want to create it?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) kubectl create namespace ${NAMESPACE};msg_info "The namespace ${NAMESPACE} was created"; break;;
        No ) exit;;
    esac
    done
  fi

}

function startup_script(){
  purgelog
  
  mkdir -p logs
  
  exec > >(tee -i ./logs/helm_flowmanager_$(date +"%Y-%m-%d_%H-%M").log)

  namespace_choice

  type -P kubectl &>/dev/null && msg_info 'kubectl is installed.'|| msg_error 'Error: kubectl is not installed.'
  type -P ${HELM} &>/dev/null && msg_info 'helm is installed.'|| msg_error 'Error: Helm is not installed.'

  msg_info "Check if namespace ${NAMESPACE} exist"
  # verify that the namespace exists
  kubectl get namespace ${NAMESPACE} --no-headers --output=go-template={{.metadata.name}} >/dev/null 2>&1
  if [ "$?" -ne "0" ]; then
    msg_error "Namespace ${NAMESPACE} not found"
    kubectl create namespace ${NAMESPACE}
  else
    msg_output "Namespace ${NAMESPACE} found"
  fi

  msg_output 'Current context set on the namespace flowmanager'
  kubectl config set-context --current --namespace=${NAMESPACE}

}
###########################################
# Purge logs function
###########################################
function purgelog() {
    msg_info 'Purge existing logs older than 10 minutes ago'
    for deleting in $(find helm_flowmanager_*.log -cmin -10); do
        msg_output "Log file deleted: $(echo $deleting)"
        rm -rf $deleting
    done
}

###########################################
# function helm history
###########################################
function helm_history() {

    msg_info "Helm Charts History"

    LIST=$($HELM list --namespace ${NAMESPACE} | grep flowmanager | awk '{print $1}')
    for i in ${LIST}
    do
      msg_output "Helm chart ${i}"
      $HELM history $i -n ${NAMESPACE} 
    done
}
###########################################
# function helm stack_create_1node
###########################################
function stack_create_1node() {
  mongodb_deploy_standalone
  redis_deploy_standalone
  flowmanager_deploy_standalone
}

function stack_create_3nodes() {
  mongodb_deploy_ha
  redis_deploy_ha
  flowmanager_deploy_ha
}
###########################################
# check stack deletion function
###########################################
function stack_confirm_deletion() {
    msg_info 'Stack deletion step'
    read -p "Continue (y/n)?" choice
    case "$choice" in
    y | Y)
        exec > >(tee -i ./logs/helm_flowmanager_$(date +"%Y-%m-%d_%H-%M").log)
        stack_deletion
        ;;
    n | N)
        exit 1
        ;;
    *)
        echo "invalid choice"
        ;;
    esac
}

function stack_deletion() {
  msg_error 'Starting Stack deletion'
  LIST=$($HELM list --namespace ${NAMESPACE} | grep flowmanager | awk '{print $1}')
  for i in ${LIST}
  do
    $HELM delete $i -n ${NAMESPACE} 
  done

  kubectl delete pvc -l app=flowmanager-mongodb -n ${NAMESPACE}
  kubectl delete pvc -l app=flowmanager-redis -n ${NAMESPACE}
}

function yaml_parse_file() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'

  echo ""
}

function values_file_edit() {
    local VALUES_FILE=$1
    local HELM_PACKAGE=$2

    msg_info 'Parameters Validation step'
    
    yaml_parse_file ${VALUES_FILE} ${HELM_PACKAGE}

    echo ""
    read -p "Continue (y/n)?" choice
    case "$choice" in
    y | Y)
        msg_info "Installation/Upgrade on going with this values file: ${VALUES_FILE}"
        ;;
    n | N)
        msg_error "Please update the file ${VALUES_FILE} and relaunch the script"
        exit 1
        ;;
    *)
        msg_error "invalid choice"
        exit 1
        ;;
    esac
}