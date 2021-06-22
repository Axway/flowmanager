# Kubernetes

Kubernetes deployment manifests files.

* [Deploy using Kubernetes standard files](standard/)
* [Deploy using Helm charts](helm/)
* [Deploy using flowmanager_helper.sh](/)

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

## Mongo/Redis
  
### Prerequisites
  * A Kubernetes 1.4+ cluster with Beta APIs enabled  
  * Helm installed in your cluster  
  * Helm CLI installed in your PC  
    
    Note: Mongodb/Redis are not maintained by Axway, check [Bitnami MongoDB](https://bitnami.com/stack/mongodb/helm) and [Bitnami Redis](https://bitnami.com/stack/redis/helm)
### Instalation steps
   * Customize [mongodb.yaml](base/mongodb.yaml) and [redis.yaml](base/redis.yaml) according to your needs. 
   * Install Redis and/or MongoDB using
     >```./flowmanager_helper.sh -m ``` for MongoDB  
     >```./flowmanager_helper.sh -r ``` for Redis
   

## Installation steps for Kubernetes with Standard Manifest Files

### Prerequisites  

* Kubernetes 1.4+
* kubectl 1.4+
* Helm 2.16+ / Helm 3+ (only for Mongo/Redis)
* Nginx installed and configured (only for Ingress)

### Steps  
1. Customize [mongodb.yaml](base/mongodb.yaml) and [redis.yaml](base/redis.yaml) according to your needs. 
2. Install Redis and/or MongoDB using
   >```./flowmanager_helper.sh -m ``` for MongoDB  
   >```./flowmanager_helper.sh -r ``` for Redis
3. Create the TLS secret for your domain using:
   >``` kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>```
4. Copy your license to the [root folder](./) or run the following command in order to create the secret:
   >```kubectl create secret generic flowmanager-license --from-file=license.xml -n <NAMESPACE>```
5. Generate the certificates and secrets using:
   >```./flowmanager_helper.sh -gc```
6. Customize [patch.yml](standard/multinode/patch.yml) and [ingress.yml](standard/multinode/ingress.yml) for FM MultiNode and/or [patch.yml](standard/singlenode/patch.yml) and [ingress.yml](standard/singlenode/ingress.yml) for FM SingleNode
7. Install Flow Manager:
   >```./flowmanager_helper.sh -fm-s ``` for FM SingleNode  
   >```./flowmanager_helper.sh -fm-m ``` for FM MultiNode 
