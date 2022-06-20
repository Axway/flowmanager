#!/bin/bash
# set -x

###########################################
# deploy redis
###########################################
function redis_deploy_standalone() {

    values_file_edit ${FILE_REDIS} "redis_chart_"

    msg_info 'Starting redis deployment standalone'
    msg_output 'Starting redis helm chart installation'
	helm repo add bitnami https://raw.githubusercontent.com/bitnami/charts/eb5f9a9513d987b519f0ecd732e7031241c50328/bitnami || echo "Repo already exists"
    $HELM upgrade --install flowmanager-redis -f ${FILE_REDIS} bitnami/redis --version 14.8.8 --namespace=${NAMESPACE} --wait

    if [ "$?" -ne "0" ]; then
        msg_error 'Helm chart deployment failed'
        $HELM delete flowmanager-redis
        exit
    else
      msg_output "Helm chart deployment done"
    fi

    msg_output 'Waiting redis ready'
    REDIS_ST="flowmanager-redis-master-0"
    kubectl wait pod/${REDIS_ST} --namespace=${NAMESPACE} --for=condition=Ready --timeout=-50s || oc wait pod/${REDIS_ST} --namespace=${NAMESPACE} --for=condition=Ready --timeout=-50s
}

function redis_check_logs() {
        msg_output "Logs for container redis"
        kubectl --tail=100 logs  -l app=flowmanager-redis  -c redis -n ${NAMESPACE} || oc --tail=100 logs  -l app=flowmanager-redis  -c redis -n ${NAMESPACE}
}

function redis_check_logs_oc() {
        msg_output "Logs for container redis"
        oc --tail=100 logs  -l app=flowmanager-redis  -c redis -n ${NAMESPACE} || oc --tail=100 logs  -l app=flowmanager-redis  -c redis -n ${NAMESPACE}
}

function redis_get_config() {
    msg_output "Config for redis"
    $HELM get values flowmanager-redis -n ${NAMESPACE}
}