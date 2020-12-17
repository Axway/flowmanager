#!/bin/bash
# set -x

function flowmanager_deploy_standard_multinode(){
    msg_info 'Starting flowmanager deployment multinode using K8S'

    kubectl apply -k ../multinode/ -n ${NAMESPACE}
    msg_info 'The resources were created, wait until the pods are running. PRESS CTRL+C to close!'
    watch kubectl get pods -n ${NAMESPACE}
}
