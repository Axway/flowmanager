#!/bin/bash
# set -x

source $(dirname $0)/helm/helper_functions/msg_functions.sh
source $(dirname $0)/helm/helper_functions/helm_functions.sh
source $(dirname $0)/dbs/helper_functions/mongodb_functions.sh
source $(dirname $0)/dbs/helper_functions/redis_functions.sh
source $(dirname $0)/helm/helper_functions/flowmanger_functions.sh
source $(dirname $0)/helm/helper_functions/gen_secrets.sh
source $(dirname $0)/standard/helper_functions/flowmanager_multi.sh
source $(dirname $0)/standard/helper_functions/flowmanager_single.sh


export HELM="helm"
export FILE_FM=$(dirname $0)/helm/flowmanager.yaml
export FILE_REDIS=$(dirname $0)/dbs/redis.yaml
export FILE_MONGO=$(dirname $0)/dbs/mongodb.yaml


###########################################
# main
###########################################

if [ $# -eq 0 ] || [ "$1" == "-h" ] ; then
cat <<USAGE
usage: $0 args
      ################
      ###Kubernetes###
      ################
      [-gc]                       Generate certs & Create secrets        
      [-fm-s | -fm-singlenode]    FM SingleNode  K8S files
      [-fm-m | -fm-multinode]     FM MultiNode   K8S files
      [-fm-h ]                    FM             Helm
      [-r | -redis]               Redis          Helm
      [-m | -mongodb]             MongoDb        Helm
      [-da | -delete-all]         Delete all resources
      [-logs-fm]                  Logs FlowManager
      [-logs-mongodb]             Logs Mongodb
      [-logs-redis]               Logs Redis
      ###############  
      ###OpenShift###
      ###############
      [-gco]                      Generate certs & Create secrets
      [-fm-ho]                    FM            Helm
      [-ro | -redis-openshift]    Redis         Helm
      [-mo | -mongodb-openshift]  MongoDb       Helm
      [-dao | -delete-all-oc]     Delete all resources
      [-logs-fm-oc]               Logs FlowManager
      [-logs-mongodb-oc]          Logs Mongodb
      [-logs-redis-oc]            Logs Redis
sample:
 ./helm-helper.sh -gc -fm
or
 ./helm-helper.sh -fm-singlenode
USAGE
exit 1
fi

while [[ "$#" -gt 0 ]]
do  
    case "$1" in
        -gc | -gen-certs) namespace_choice && gen_certs_selfsigned ;;
	    -fm-s | -fm-singlenode) namespace_choice && flowmanager_deploy_standard_standalone ;;
	    -fm-m | -fm-multinode)  namespace_choice && flowmanager_deploy_standard_multinode ;;
	    -gc | -gen-certs) namespace_choice && gen_certs_selfsigned ;;
		-gco | -gen-certs-openshift) namespace_choice_oc && gen_certs_selfsigned_oc ;;
        -fm-h | -flowmanager-helm)  startup_script && flowmanager_deploy_standalone ;;
		-fm-ho | -flowmanager-helm-openshift)  startup_script_oc && flowmanager_deploy_standalone_oc ;;
        -r | -redis) startup_script && redis_deploy_standalone ;;
        -m | -mongodb) startup_script && mongodb_deploy_standalone ;;
		-ro | -redis-openshift) startup_script_oc && redis_deploy_standalone ;;
        -mo | -mongodb-openshift) startup_script_oc && mongodb_deploy_standalone ;;
        -da | -delete-all) namespace_choice && stack_confirm_deletion ;;
		-dao | -delete-all-oc) namespace_choice_oc && stack_confirm_deletion_oc ;;
        -logs-fm) namespace_choice && fm_check_logs ;;
		-logs-fm-oc) namespace_choice_oc && fm_check_logs_oc ;;
        -logs-mongodb) namespace_choice && mongodb_check_logs ;;
        -logs-redis) namespace_choice && redis_check_logs ;;
		-logs-mongodb-oc) namespace_choice_oc && mongodb_check_logs_oc ;;
        -logs-redis-oc) namespace_choice_oc && redis_check_logs_oc ;;
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

