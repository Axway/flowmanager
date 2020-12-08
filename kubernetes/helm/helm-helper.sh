#!/bin/bash
# set -x

source $(dirname $0)/helper_functions/msg_functions.sh
source $(dirname $0)/helper_functions/helm_functions.sh
source $(dirname $0)/helper_functions/mongodb_functions.sh
source $(dirname $0)/helper_functions/redis_functions.sh
source $(dirname $0)/helper_functions/flowmanger_functions.sh
source $(dirname $0)/helper_functions/gen_certs.sh

export HELM="helm"
export FILE_FM=$(dirname $0)/flowmanager.yaml
export FILE_REDIS=$(dirname $0)/redis.yaml
export FILE_MONGO=$(dirname $0)/mongodb.yaml


msg_info "You are using those Values files"
echo ""
printenv | grep 'FILE_'
echo ""
###########################################
# main
########################################### 
while [[ "$#" -gt 0 ]]
do
    case "$1" in
        -gc | -gen-certs) namespace_choice && gen_certs_selfsigned ;;
        -fm | -flowmanager)  startup_script && flowmanager_deploy_standalone ;;
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
      [-fm | -flowmanager]
      [-r | -redis]
      [-m | -mongodb]
      [-full | -fullstack]
      [-hi | -history]
      [-da | -delete-all]
      [-logs-fm]
      [-logs-mongodb]
      [-logs-redis]
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

