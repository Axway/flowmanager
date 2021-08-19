# Kubernetes

Kubernetes deployment manifests files.

* [Deploy using flowmanager_helper.sh(Helm Charts or standard Kubernetes files)](/)
* [Deploy using standard Kubernetes files](standard/)
* [Deploy using Helm charts](helm/)
* [Deploy MongoDB/Redis](kubernetes/base)

## Flowmanager helper script

```shell
usage: ./flowmanager_helper.sh args
      [-gc | -gen-certs]
      [-fm-s | -fm-singlenode]
      [-fm-m | -fm-multinode]
      [-fm-h | -flowmanager]
      [-r | -redis]
      [-m | -mongodb]
      [-hi | -history]
      [-da | -delete-all]
      [-logs-fm]
      [-logs-mongodb]
      [-logs-redis]
sample:
 ./helm-helper.sh -gc -fm
or
 ./helm-helper.sh -flowmanager
```

 _Options:_

 - **[-gc | -gen-certs]**       : Generate certificates and create kubernetes secrets.
 - **[-fm-s | -fm-singlenode]** : Install FlowManager SingleNode using standard K8S. [Change the values here](standard/singlenode/)
 - **[-fm-m | -fm-multinode]**  : Install FlowManager MultiNode using standard K8S. [Change the values here](standard/multinode/)
 - **[-fm-h | -fm-flowmanager]**: Install FlowManager MultiNode using Helm. [Change the values here](helm/flowmanager.yaml)
 - **[-r | -redis]**            : Install Redis using Helm.[Change the values here](helm/redis.yaml)
 - **[-m | -mongodb]**          : Install MongoDb using Helm.[Change the values here](helm/mongodb.yaml)
 - **[-hi | -history]**         : Check Helm logs under namespace.
 - **[-da | -delete-all]**      : Delete all the resources from namespace.
 - **[-logs-fm]**               : Check FlowManager logs.
 - **[-logs-mongodb]**          : Check MongoDb logs.
 - **[-logs-redis]**            : Check Redis logs.
