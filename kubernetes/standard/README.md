## Installation steps for Kubernetes with Standard Manifest Files using flowmanager_helper.sh

### Prerequisites  

* Kubernetes 1.17 and higher
* Helm 3+ (only for Mongo/Redis)
* Customer license and certificates
* Mongodb 4.2 (can be installed with flowmanager_helper.sh -m)
* Redis (only for Flowmanager Multinode, can be installed with flowmanager_helper.sh -r)
* Nginx 1.15 and higher, installed and configured for Ingress usage
* SSL certificate

### Steps  
1. Customize [mongodb.yaml](/kubernetes/base/mongodb.yaml) and [redis.yaml](/kubernetes/base/redis.yaml) according to your needs. 
2. Install Redis and/or MongoDB using
   >```./flowmanager_helper.sh -m ``` for MongoDB  (Kubernetes)  
   >```./flowmanager_helper.sh -r ``` for Redis    (Kubernetes)  
   >```./flowmanager_helper.sh -mo ``` for MongoDB  (OpenShift)  
   >```./flowmanager_helper.sh -ro ``` for Redis    (OpenShift)  
3. Create the TLS secret for your domain using (mandatory for ST-Plugin):
   >``` kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>```
   For OpenShift clusters, replace _kubectl_ with _oc_.
4. Copy your license to the [root folder](./) or run the following command in order to create the secret:
   >```kubectl create secret generic license --from-file=license.xml -n <NAMESPACE>```
   For OpenShift clusters, replace _kubectl_ with _oc_.
5. Generate the certificates and secrets using:
   >```./flowmanager_helper.sh -gc``` (Kubernetes)
   >```./flowmanager_helper.sh -gco``` (OpenShift)
6. Customize [patch.yml](./multinode/patch.yml) and [ingress.yml](./multinode/ingress.yml) for FM MultiNode and/or [patch.yml](./singlenode/patch.yml) and [ingress.yml](./singlenode/ingress.yml) for FM SingleNode. You can add and remove any parameter from patch.yml, please check [docs](/docs/).
7. Install Flow Manager:
   >```./flowmanager_helper.sh -fm-s ``` for FM SingleNode  (Kubernetes)  
   >```./flowmanager_helper.sh -fm-m ``` for FM MultiNode   (Kubernetes)  
   >```./flowmanager_helper.sh -fm-s ``` for FM SingleNode  (Kubernetes)  
   >```.oc apply -k ./singlenode -n <namespace>``` for FM SingleNode(OpenShift cluster)  
   >```.oc apply -k ./multinode -n <namespace>```  for FM MultiNode(OpenShift cluster)  


## Deploy using standard files

Deploy using standard Kubernetes deployment manifest files.

### Prerequisites

* Kubernetes 1.17 and higher
* Customer license and certificates
* Mongodb 4.2 (can be installed with flowmanager_helper.sh -m)
* Redis (only for Flowmanager Multinode, can be installed with flowmanager_helper.sh -r)
* Nginx(latest stable version) installed and configured for Ingress usage
* SSL certificate

### How to create secrets for certificates


```shell
kubectl create secret generic license --from-file=./license.xml -n <NAMESPACE>
kubectl create secret generic st-fm-plugin-ca --from-file=./certs/st-fm-plugin-ca.pem -n <NAMESPACE>
kubectl create secret generic uicert --from-file=./certs/uicert.pem -n <NAMESPACE> (if needed)
kubectl create secret generic st-fm-plugin-ca --from-file=./certs/st-fm-plugin-ca.pem -n <NAMESPACE>
kubectl create secret generic st-fm-plugin-cert-key --from-file=./certs/st-fm-plugin-cert-key.pem -n <NAMESPACE>
kubectl create secret generic st-fm-plugin-cert --from-file=./certs/st-fm-plugin-cert.pem -n <NAMESPACE>
kubectl create secret generic private-key-st --from-file=./certs/private-key -n <NAMESPACE>
kubectl create secret generic public-key-st --from-file=./certs/public-key -n <NAMESPACE>
kubectl create secret generic governanceca --from-file=./certs/governanceca.pem -n <NAMESPACE>
kubectl create secret generic st-fm-plugin-shared-secret --from-file=./certs/st-fm-plugin-shared-secret -n <NAMESPACE>
kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>
```

### How to create secrets env variables


Updating each values for the keys related:

```shell
  FM_GENERAL_ENCRYPTION_KEY: ""
  FM_HTTPS_KEYSTORE_PASSWORD: ""
  FM_CFT_SHARED_SECRET: ""
  FM_DATABASE_USER_NAME: ""
  FM_DATABASE_USER_PASSWORD: ""
  FM_GOVERNANCE_CA_PASSWORD: ""
  ST_FM_PLUGIN_DATABASE_USER_PASSWORD: "" 
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

* Deployment file: [SingleNode](./singlenode/patch.yml) or [MultiNode](./multinode/patch.yml)

### How to deploy Flowmanager


1. Creating manually all secrets for the licence and certificates including tls certificate
2. Editing manually the yaml file for parameters needed or madatory for the customer. You can add and remove any parameter from patch.yml, please check [docs](/docs/).
3. Applying all the files
ex:

```shell
kubectl apply -k ./singlenode -n <namespace>
or
kubectl apply -k ./multinode -n <namespace>
```

### ***Remove***

```shell
kubectl delete -k ./singlenode -n <namespace>
```
