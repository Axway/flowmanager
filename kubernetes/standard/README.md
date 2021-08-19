
## Installation steps for Kubernetes with Standard Manifest Files using flowmanager_helper.sh

### Prerequisites  

* Kubernetes 1.4+
* kubectl 1.4+
* Helm 3+ (only for Mongo/Redis)
* Nginx(latest stable version) installed and configured for Ingress usage 

### Steps  
1. Customize [mongodb.yaml](kubernetes/base/mongodb.yaml) and [redis.yaml](kubernetes/base/redis.yaml) according to your needs. 
2. Install Redis and/or MongoDB using
   >```./flowmanager_helper.sh -m ``` for MongoDB  
   >```./flowmanager_helper.sh -r ``` for Redis
3. Create the TLS secret for your domain using:
   >``` kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>```
4. Copy your license to the [root folder](./) or run the following command in order to create the secret:
   >```kubectl create secret generic flowmanager-license --from-file=license.xml -n <NAMESPACE>```
5. Generate the certificates and secrets using:
   >```./flowmanager_helper.sh -gc```
6. Customize [patch.yml](standard/multinode/patch.yml) and [ingress.yml](standard/multinode/ingress.yml) for FM MultiNode and/or [patch.yml](standard/singlenode/patch.yml) and [ingress.yml](standard/singlenode/ingress.yml) for FM SingleNode and [Secret Env file](base/secret-env.yml)
7. Install Flow Manager:
   >```./flowmanager_helper.sh -fm-s ``` for FM SingleNode  
   >```./flowmanager_helper.sh -fm-m ``` for FM MultiNode 


## Deploy using standard files

Deploy using standard Kubernetes deployment manifest files.

### Prerequisites

* Kubernetes 1.4+
* kubectl 1.4+
* Customer certificates and password
* Customer license
* Mongodb URL
* `user` and `password` for Mongodb
* Nginx(latest stable version) installed and configured for Ingress usage

### How to create secrets for certificates

* License

```shell
kubectl create secret generic flowmanager-license --from-file=license.xml
```

* UI

```shell
kubectl create secret generic flowmanager-httpskeystore --from-file=uicert.p12
```

* Governance

```shell
kubectl create secret generic flowmanager-governance --from-file=governanceca.p12
```

_**Warning:** Each files used from this step we need to be update the [Deployment file](flowmanager/deployment.yaml)_

### How to create secrets for monogdb credentials or redis

Inside the file [secret-env.yml](standard/base/secret-env.yml)

Updating each values for the keys related:

```shell
  FM_GENERAL_ENCRYPTION_KEY: ""
  FM_HTTPS_KEYSTORE_PASSWORD: ""
  FM_CFT_SHARED_SECRET: ""
  FM_DATABASE_USER_NAME: ""
  FM_DATABASE_USER_PASSWORD: ""
  FM_GOVERNANCE_CA_PASSWORD: ""
```

Example with mongodb user/password:

```shell
# For mongodb user
$ echo -n 'mongdb_user' | base64
bW9uZ2RiX3VzZXI=
# Changing the value for the key
FM_DATABASE_USER_NAME: "bW9uZ2RiX3VzZXI="

# For mongodb password
$ echo -n 'mongdb_password' | base64
bW9uZ2RiX3Bhc3N3b3Jk
# Changing the value for the key
FM_DATABASE_USER_PASSWORD: "bW9uZ2RiX3Bhc3N3b3Jk"
```

### How to configure Flowmanager before deployment

Files to check and modify:

* Deployment file: [SingleNode](singlenode/patch.yml) or [MultiNode](multinode/patch.yml)
* [Secret Env file](base/secret-env.yml)

### How to deploy Flowmanager

**This stuff permit to deploy only Flowmanager 1 node**

1. Creating manually all secrets for the licence and certificates
2. Editing manually the yaml file for parameters needed or madatory for the customer
3. Applying all the files
ex:

```shell
kubectl apply -k ./singlenode
```

### ***Remove***

```shell
kubectl delete -k ./singlenode
```
