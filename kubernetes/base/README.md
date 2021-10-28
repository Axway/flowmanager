## Mongo/Redis
  
### Prerequisites
  * A Kubernetes 1.7 and higher
  * Helm 3+
    
    Note: Mongodb/Redis are not maintained by Axway, check [Bitnami MongoDB](https://bitnami.com/stack/mongodb/helm) and [Bitnami Redis](https://bitnami.com/stack/redis/helm)
### Instalation steps
   * Customize [mongodb.yaml](kubernetes/base/mongodb.yaml) and [redis.yaml](kubernetes/base/redis.yaml) according to your needs. The user and password are mandatory to be changed.
   * Install Redis and/or MongoDB using
     >```./flowmanager_helper.sh -m ``` for MongoDB  
     >```./flowmanager_helper.sh -r ``` for Redis
