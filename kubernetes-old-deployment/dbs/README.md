## Mongo
  
### Prerequisites
  * A Kubernetes 1.7 and higher
  * Helm 3+
    
    Note: Mongodb are not maintained by Axway, check [Bitnami MongoDB](https://bitnami.com/stack/mongodb/helm)
### Instalation steps
   * Customize [mongodb.yaml](/kubernetes/base/mongodb.yaml) according to your needs. The user and password are mandatory to be changed.
   * Install MongoDB using
     >```./flowmanager_helper.sh -m ``` for MongoDB  
