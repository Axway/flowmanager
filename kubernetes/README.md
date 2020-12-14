# Kubernetes

Kubernetes deployment manifests files.

* [Deploy using Kubernetes standard files](standard/)
* [Deploy using Helm charts](helm/)
* [Deploy using helper.sh](/)

usage: ./helper.sh args
      [-gc|-gen-certs]
      [-fm-s | -fm-singlenode] FM SingleNode standard K8S
      [-fm-m | -fm-multinode]  FM MultiNode  standard K8S
      [-fm-h | -flowmanager]   FM            Helm
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

 - [-gc|-gen-certs] : Generate certificates and create kubernetes secrets.
 - [-fm-s | -fm-singlenode] : Install FlowManager 1Node using standard K8S. [Change the values here](/standard/singlenode/)

