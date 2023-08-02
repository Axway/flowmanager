#!/bin/bash
# set -x

###########################################
# deploy mongodb
###########################################
function mongodb_deploy_standalone() {

    values_file_edit ${FILE_MONGO} "mongodb_chart_"

    msg_info 'Starting mongodb deployment standalone'
    msg_output 'Starting mongodb helm chart installation'
	$HELM upgrade --install flowmanager-mongodb -f ${FILE_MONGO} bitnami/mongodb --namespace=${NAMESPACE} --wait

    if [ "$?" -ne "0" ]; then
        msg_error 'Helm chart deployment failed'
        $HELM delete flowmanager-mongodb --namespace=${NAMESPACE} 
        exit
    else
      msg_output "Helm chart deployment done"
    fi

    msg_output 'Waiting mongodb ready'
    MONGODB_POD=$(kubectl get pods -n ${NAMESPACE} | grep flowmanager-mongodb | sed -n 1p | awk '{print $1}')
    kubectl wait pod/${MONGODB_POD} --namespace=${NAMESPACE} --for=condition=Ready --timeout=-50s
}


function mongodb_check_logs() {
    msg_output "Logs for mongodb"
    kubectl --tail=100 logs  -l app=flowmanager-mongodb -n ${NAMESPACE}
}

function mongodb_get_config() {
    msg_output "Config for mongodb"
    $HELM get values flowmanager-mongodb -n ${NAMESPACE}
}