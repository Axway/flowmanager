# Kubernetes

Kubernetes deployment manifests files.

* [Deploy using Kubernetes standard files](standard/)
* [Deploy using Helm charts](helm/)
* [Deploy using helper.sh](/)

# How to deploy FlowManager with Helm
* Generate certificates and secrets by running `./helper.sh -gc`
* Editing manually the yaml file for parameters needed or madatory for the customer ([flowmanager.yaml](helm/flowmanager.yaml) and [mongodb.yaml](helm/mongodb.yaml)) 
* Install MongoDb using helm by running `./helper.sh -m`
* Install MongoDb using helm by running `./helper.sh -fm-h`

> For more information about MongoDb with Helm, please access [this link](https://bitnami.com/stack/mongodb/helm).


```
usage: ./helper.sh args
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
 - **[-r | -redis]**            : Install Redis using helm.[Change the values here](helm/redis.yaml)
 - **[-m | -mongodb]**          : Install MongoDb using helm.[Change the values here](helm/mongodb.yaml)
 - **[-hi | -history]**         : Check Helm logs under namespace.
 - **[-da | -delete-all]**      : Delete all the resources from namespace.
 - **[-logs-fm]**               : Check FlowManager logs.
 - **[-logs-mongodb]**          : Check MongoDb logs.
 - **[-logs-redis]**            : Check Redis logs.
 


