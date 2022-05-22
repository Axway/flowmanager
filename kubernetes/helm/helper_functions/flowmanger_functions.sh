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
    helm repo update axway
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

    msg_output 'Waiting flowmanager ready'
    FM_POD=$(kubectl get pods -n ${NAMESPACE} | grep flowmanager | sed -n 1p | awk '{print $1}')
    kubectl wait pod/${FM_POD} --namespace=${NAMESPACE} --for=condition=Ready --timeout=-20s

    rm -rf ./flowmanager/config
    fm_end_script ${FILE_FM}
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
    helm repo update axway
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

    msg_output 'Waiting flowmanager ready'
    FM_POD=$(oc get pods -n ${NAMESPACE} | grep flowmanager | sed -n 1p | awk '{print $1}')
    oc wait pod/${FM_POD} --namespace=${NAMESPACE} --for=condition=Ready --timeout=-20s

    rm -rf ./flowmanager/config
    fm_end_script ${FILE_FM}
}


function fm_end_script() {
    local VALUES_FILE=$1

    INGRESS_YES=$(yq r ${VALUES_FILE} 'ingress.enabled')
    SERVICE_TYPE=$(yq r ${VALUES_FILE} 'service.type')

    if [ "${INGRESS_YES}" == "true" ]; then
        printf ${YELLOW} "[INFOS]"
        printf ${YELLOW} "[INFOS] ===================================================="
        printf ${YELLOW} "[INFOS]  DATE : $(date +"%Y-%m-%d_%H:%M:%S")"
        printf ${YELLOW} "[INFOS]  "
        printf ${YELLOW} "[INFOS]  Flomanager Url : https://$(kubectl get ing/flowmanager -o jsonpath='{.spec.rules[0].host}')"
        printf ${YELLOW} "[INFOS]  "
        printf ${YELLOW} "[INFOS] ===================================================="
        printf ${YELLOW} "[INFOS]  "

    elif [ "${SERVICE_TYPE}" == "LoadBalancer" ]; then
        printf ${YELLOW} "[INFOS]"
        printf ${YELLOW} "[INFOS] ===================================================="
        printf ${YELLOW} "[INFOS]  DATE : $(date +"%Y-%m-%d_%H:%M:%S")"
        printf ${YELLOW} "[INFOS]  "
        printf ${YELLOW} "[INFOS]  Flomanager Url : https://$(kubectl get svc/flowmanager -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
        printf ${YELLOW} "[INFOS]  "
        printf ${YELLOW} "[INFOS] ===================================================="
        printf ${YELLOW} "[INFOS]  "
    else
        printf ${YELLOW} "[INFOS]"
        printf ${YELLOW} "[INFOS] ===================================================="
        printf ${YELLOW} "[INFOS]  DATE : $(date +"%Y-%m-%d_%H:%M:%S")"
        printf ${YELLOW} "[INFOS]  "
        printf ${YELLOW} "[INFOS]  Internal Flomanager Url : http://flowmanager.flowmanager.svc.cluster.local')"
        printf ${YELLOW} "[INFOS]  "
        printf ${YELLOW} "[INFOS] ===================================================="
        printf ${YELLOW} "[INFOS]  "        
    fi
    kubectl get all
    kubectl get ingress
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
