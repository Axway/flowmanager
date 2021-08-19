#!/bin/bash
# set -x

source $(dirname $0)/helm/helper_functions/msg_functions.sh
source $(dirname $0)/helm/helper_functions/helm_functions.sh
source $(dirname $0)/base/helper_functions/mongodb_functions.sh
source $(dirname $0)/base/helper_functions/redis_functions.sh
source $(dirname $0)/helm/helper_functions/flowmanger_functions.sh
source $(dirname $0)/helm/helper_functions/gen_secrets.sh
source $(dirname $0)/standard/helper_functions/flowmanager_multi.sh
source $(dirname $0)/standard/helper_functions/flowmanager_single.sh


export HELM="helm"
export FILE_FM=$(dirname $0)/helm/flowmanager.yaml
export FILE_REDIS=$(dirname $0)/base/redis.yaml
export FILE_MONGO=$(dirname $0)/base/mongodb.yaml


msg_info "Starting script"

###########################################
# main
########################################### 
while [[ "$#" -gt 0 ]]
do
    case "$1" in
        -gc | -gen-certs) namespace_choice && gen_certs_selfsigned ;;
	    -fm-s | -fm-singlenode) namespace_choice && flowmanager_deploy_standard_standalone ;;
	    -fm-m | -fm-multinode)  namespace_choice && flowmanager_deploy_standard_multinode ;;
	    -gc | -gen-certs) namespace_choice && gen_certs_selfsigned ;;
        -fm-h | -flowmanager-helm)  startup_script && flowmanager_deploy_standalone ;;
        -r | -redis) startup_script && redis_deploy_standalone ;;
        -m | -mongodb) startup_script && mongodb_deploy_standalone ;;
        -hi | -history) namespace_choice && helm_history ;;
        -da | -delete-all) namespace_choice && stack_confirm_deletion ;;
        -logs-fm) namespace_choice && fm_check_logs ;;
        -logs-mongodb) namespace_choice && mongodb_check_logs ;;
        -logs-redis) namespace_choice && redis_check_logs ;;

        -?)  cat <<USAGE
usage: $0 args
      [-gc|-gen-certs] 
      [-fm-s | -fm-singlenode] FM SingleNode standard K8S
      [-fm-m | -fm-multinode]  FM MultiNode  standard K8S
      [-fm-h | -flowmanager]   FM            Helm
      [-r | -redis]            Redis         Helm
      [-m | -mongodb]          MongoDb       Helm
      [-hi | -history]         Delete helm history
      [-da | -delete-all]      Delete all resources
      [-logs-fm]               Logs FlowManager
      [-logs-mongodb]          Logs Mongodb
      [-logs-redis]            Logs Redis
sample:
 ./helm-helper.sh -gc -fm
or
 ./helm-helper.sh -flowmanager
USAGE
            exit 1
            ;;
        *)
            msg_error "Unknown parameter passed"
            break;
            ;;
    esac
    shift       # toss current $1; we're done with it now
done

for p in "$@"
do
    msg_error "Non-option argument: '$p'"
done

