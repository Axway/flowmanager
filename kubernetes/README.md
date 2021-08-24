# Kubernetes

Kubernetes deployment manifests files.

* [Deploy using flowmanager_helper.sh(Helm Charts or standard Kubernetes files)](/)
* [Deploy using standard Kubernetes files](standard/)
* [Deploy using Helm charts](helm/)
* [Deploy MongoDB/Redis](kubernetes/base)

## Flowmanager helper script

```shell
usage: ./flowmanager_helper.sh args
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
 ./helm-helper.sh -gc -fm-h
or
 ./helm-helper.sh -fm-singlenode
```

 _Options:_
 - **[-gc]**                   : Generate certificates and create kubernetes secrets.
 - **[-fm-s | -fm-singlenode]** : Install FlowManager SingleNode using standard K8S. [Change the values here](standard/singlenode/)
 - **[-fm-m | -fm-multinode]**  : Install FlowManager MultiNode using standard K8S. [Change the values here](standard/multinode/)
 - **[-fm-h | -fm-flowmanager]**: Install FlowManager MultiNode using Helm. [Change the values here](helm/flowmanager.yaml)
 - **[-r | -redis]**            : Install Redis using Helm.[Change the values here](helm/redis.yaml)
 - **[-m | -mongodb]**          : Install MongoDb using Helm.[Change the values here](helm/mongodb.yaml)
 - **[-da | -delete-all]**      : Delete all the resources from a namespace.
 - **[-logs-fm]**               : Check FlowManager logs.
 - **[-logs-mongodb]**          : Check MongoDb logs.
 - **[-logs-redis]**            : Check Redis logs.
 - **[-gco]**                   : Generate certificates and create kubernetes secrets in a OpenShift cluster.
 - **[-fm-ho]**                 : Install FlowManager MultiNode using Helm in a OpenShift cluster. [Change the values here](helm/flowmanager.yaml)
 - **[-ro | -redis-openshift]**    : Install Redis using Helm in a OpenShift cluster.[Change the values here](helm/redis.yaml)
 - **[-mo | -mongodb-openshift]**  : Install MongoDb using Helm in a OpenShift cluster.[Change the values here](helm/mongodb.yaml)
 - **[-dao | -delete-all-oc]**     : Delete all the resources from a namespace in a OpenShift cluster.
 - **[-logs-fm-oc]**               : Check FlowManager logs in a OpenShift cluster.
 - **[-logs-mongodb-oc]**          : Check MongoDb logs in a OpenShift cluster .
 - **[-logs-redis-oc]**            : Check Redis logs in a OpenShift cluster.
