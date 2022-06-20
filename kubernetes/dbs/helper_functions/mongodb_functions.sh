#!/bin/bash
# set -x

###########################################
# deploy mongodb
###########################################
function mongodb_deploy_standalone() {

    values_file_edit ${FILE_MONGO} "mongodb_chart_"

    msg_info 'Starting mongodb deployment standalone'
    msg_output 'Starting mongodb helm chart installation'
	helm repo add bitnami https://raw.githubusercontent.com/bitnami/charts/eb5f9a9513d987b519f0ecd732e7031241c50328/bitnami || echo "Repo already exists"
	$HELM upgrade --install flowmanager-mongodb -f ${FILE_MONGO} bitnami/mongodb --version 10.23.10 --namespace=${NAMESPACE} --wait

    if [ "$?" -ne "0" ]; then
        msg_error 'Helm chart deployment failed'
        $HELM delete flowmanager-mongodb --namespace=${NAMESPACE} 
        exit
    else
      msg_output "Helm chart deployment done"
    fi

    msg_output 'Waiting mongodb ready'
    MONGODB_POD=$(kubectl get pods -n ${NAMESPACE} | grep flowmanager-mongodb | sed -n 1p | awk '{print $1}')
    kubectl wait pod/${MONGODB_POD} --namespace=${NAMESPACE} --for=condition=Ready --timeout=-50s || oc wait pod/${MONGODB_POD} --namespace=${NAMESPACE} --for=condition=Ready --timeout=-50s
}


function mongodb_check_logs() {
    msg_output "Logs for mongodb"
    kubectl --tail=100 logs  -l app=flowmanager-mongodb -n ${NAMESPACE} || oc --tail=100 logs  -l app=flowmanager-mongodb -n ${NAMESPACE}
}

function mongodb_check_logs_oc() {
    msg_output "Logs for mongodb"
    oc --tail=100 logs  -l app=flowmanager-mongodb -n ${NAMESPACE} || oc --tail=100 logs  -l app=flowmanager-mongodb -n ${NAMESPACE}
}


function mongodb_get_config() {
    msg_output "Config for mongodb"
    $HELM get values flowmanager-mongodb -n ${NAMESPACE}
}