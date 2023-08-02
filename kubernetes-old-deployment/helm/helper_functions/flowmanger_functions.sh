#!/bin/bash
# set -x

###########################################
# deploy flowmanager
###########################################
function flowmanager_deploy_standalone() {
    
	if [[ $(helm repo list | grep axway) ]]; then
      echo "Axway repository already exists"
    else
      echo "Please, type your Service Account:"
      read -s SERVICE_ACCOUNT
      echo "Type the password of your service account:"
      read -s SA_PASSWORD
	  msg_info 'Adding flowmanager helm repository'
	  helm repo add axway https://helm.repository.axway.com --username $SERVICE_ACCOUNT --password $SA_PASSWORD
    fi
	msg_info 'Pulling flowmanager helm chart'
    helm repo update
	helm pull axway/flowmanager-helm-prod-flowmanager
    msg_info 'Starting flowmanager deployment standalone'
    msg_output 'Starting flowmanager helm chart installation'
    $HELM upgrade --install flowmanager axway/flowmanager-helm-prod-flowmanager -f ${FILE_FM} --namespace=${NAMESPACE}

    if [ "$?" -ne "0" ]; then
        msg_error 'Helm chart deployment failed'
        $HELM delete flowmanager --namespace=${NAMESPACE}
        exit
    else
      msg_output "Helm chart deployment done"
    fi


    rm -rf ./flowmanager/config || echo "config not found"
	watch kubectl get pods -n ${NAMESPACE}
}

function flowmanager_deploy_standalone_oc() {
    
	if [[ $(helm repo list | grep axway) ]]; then
      echo "Axway repository already exists"
    else
      echo "Please, type your Service Account:"
      read -s SERVICE_ACCOUNT
      echo "Type the password of your service account:"
      read -s SA_PASSWORD
	  msg_info 'Adding flowmanager helm repository'
	  helm repo add axway https://helm.repository.axway.com --username $SERVICE_ACCOUNT --password $SA_PASSWORD
    fi
	msg_info 'Pulling flowmanager helm chart'
    helm repo update
	helm pull axway/flowmanager-helm-prod-flowmanager
    msg_info 'Starting flowmanager deployment standalone'
    msg_output 'Starting flowmanager helm chart installation'
    $HELM upgrade --install flowmanager axway/flowmanager-helm-prod-flowmanager -f ${FILE_FM} --namespace=${NAMESPACE}

    if [ "$?" -ne "0" ]; then
        msg_error 'Helm chart deployment failed'
        $HELM delete flowmanager --namespace=${NAMESPACE}
        exit
    else
      msg_output "Helm chart deployment done"
    fi

    rm -rf ./flowmanager/config || echo "config not found"
	watch oc get pods -n ${NAMESPACE}
}


function fm_check_logs() {
    msg_output "Logs for Flowmanager"
    kubectl --tail=100 logs  -l app=flowmanager -n ${NAMESPACE} || oc --tail=200 logs  -l app=flowmanager -n ${NAMESPACE}
}

function fm_check_logs_oc() {
    msg_output "Logs for Flowmanager"
    oc --tail=100 logs  -l app=flowmanager -n ${NAMESPACE} || oc --tail=200 logs  -l app=flowmanager -n ${NAMESPACE}
}

function flowmanager_get_config() {
    msg_output "Config for flowmanager"
    $HELM get values flowmanager -n ${NAMESPACE}
}
