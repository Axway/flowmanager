# Flowmanager Deployment on Kubernetes with Helm Charts

## Prerequisites

* Kubernetes 1.17+
* Helm 3+
* Customer license
* Mongodb (can be installed with _flowmanager_helper.sh -m_)
* Redis (only for Flowmanager Multinode, can be installed with _flowmanager_helper.sh -r_)
* Nginx 1.15 and higher, installed and configured for Ingress usage
* SSL certificate

## Content

* [Flowmanager deployment](./)
* [Mongodb deployment](/kubernetes/base/)
* [Redis deployment](/kubernetes/base/)

**Caution for redis and mongodb you need to accept the usage of external docker images not under Axway responsability.**

## Deploy using flowmanager_helper.sh

1. Customize [mongodb.yaml](/kubernetes/base/mongodb.yaml) and [redis.yaml](/kubernetes/base/redis.yaml) according to your needs. The user and password are mandatory to be changed.
2. Install Redis and/or MongoDB using
   >```./flowmanager_helper.sh -m ``` for MongoDB  (Kubernetes)  
   >```./flowmanager_helper.sh -r ``` for Redis    (Kubernetes)  
   >```./flowmanager_helper.sh -mo ``` for MongoDB  (OpenShift)  
   >```./flowmanager_helper.sh -ro ``` for Redis    (OpenShift)  
3. Create the TLS secret for your domain using(mandatory for ST-Plugin):
   >``` kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>```  
   For OpenShift clusters, replace _kubectl_ with _oc_.
4. Copy your license to the [root folder](kubernetes/) or run the following command in order to create the secret:
   >```kubectl create secret generic license --from-file=license.xml -n <NAMESPACE>```  
   For OpenShift clusters, replace _kubectl_ with _oc_.
5. Generate the certificates and secrets using:
   >```./flowmanager_helper.sh -gc``` (Kubernetes)  
   >```./flowmanager_helper.sh -gco``` (OpenShift)  
6. Customize [flowmanager.yaml](kubernetes/helm/flowmanager.yaml). You can add and remove any parameter from flowmanager.yaml, please check [docs](/docs/).
7. Install Flow Manager using Helm Charts:
   >```./flowmanager_helper.sh -fm-h ``` (Kubernetes)    
   >```./flowmanager_helper.sh -fm-ho ```(OpenShift)  


## Deploy using standard k8s commands
### Flowmanager

Create kubernetes secrets:
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
For OpenShift clusters, replace _kubectl_ with _oc_.

**[Flowmanager.yaml](/kubernetes/helm/flowmanager.yaml) has to be configured. You can add and remove any parameter from flowmanager.yaml, please check [docs](/docs/).**

1. **Helm deployment/upgrade**

```shell
helm dep update ./flowmanager
helm upgrade --install flowmanager ./flowmanager -f flowmanager.yaml --namespace=<your_namespace>
```

2. **Helm delete**

```shell
helm delete flowmanager --namespace=<your_namespace>
```

### Internal Mongodb on Kubernetes

**Caution internal mongodb will be not encrypted with certificate. [MongoDB.yaml](/kubernetes/base/mongodb.yaml) has to be configured.**


1. **Helm deployment/upgrade**

```shell
helm upgrade --install flowmanager-mongodb -f mongodb.yaml bitnami/mongodb --version 10.23.10 --namespace=<your_namespace>
```

2. **Helm delete**

```shell
helm delete flowmanager-mongodb --namespace=<your_namespace>
```

### Internal Redis on Kubernetes

**Caution internal redis will be not encrypted with certificate. [Redis.yaml](/kubernetes/base/redis.yaml) has to be configured.**

1. **Helm deployment/upgrade**

```shell
helm upgrade --install flowmanager-redis -f redis.yaml bitnami/redis --version 14.8.8 --namespace=<your_namespace>
```

2. **Helm delete**

```shell
helm delete flowmanager-redis --namespace=<your_namespace>
```
