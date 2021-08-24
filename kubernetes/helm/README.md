# Flowmanager Deployment on Kubernetes with Helm Charts

## Prerequisites

* Kubernetes 1.17+
* Helm 3+
* Nginx(latest stable version) installed and configured for Ingress usage

## Content

* [Flowmanager deployment](flowmanager/README.md)
* [Mongodb deployment](kubernetes/base/)
* [Redis deployment](kubernetes/base/)

**Caution for redis and mongodb you need to accept the usage of external docker images not under Axway responsability.**

## Using flowmanager_helper.sh

1. Customize [mongodb.yaml](kubernetes/base/mongodb.yaml) and [redis.yaml](kubernetes/base/redis.yaml) according to your needs. 
2. Install Redis and/or MongoDB using
   >```./flowmanager_helper.sh -m ``` for MongoDB  
   >```./flowmanager_helper.sh -r ``` for Redis
3. Create the TLS secret for your domain using(optional):
   >``` kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>```
4. Copy your license to the [root folder](kubernetes/) or run the following command in order to create the secret:
   >```kubectl create secret generic flowmanager-license --from-file=license.xml -n <NAMESPACE>```
5. Generate the certificates and secrets using:
   >```./flowmanager_helper.sh -gc```
6. Customize [flowmanager.yaml](kubernetes/helm/flowmanager.yaml)
7. Install Flow Manager using Helm Charts:
   >```./flowmanager_helper.sh -fm-h ```


## Standard Deployment
### Flowmanager

**[Flowmanager.yaml](kubernetes/helm/flowmanager.yaml) has to be configured.**

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

**Caution internal mongodb will be not encrypted with certificate. [MongoDB.yaml](kubernetes/base/mongodb.yaml) has to be configured.**


1. **Helm deployment/upgrade**

```shell
helm upgrade --install flowmanager-mongodb -f mongodb.yaml bitnami/mongodb --version 10.23.10 --namespace=<your_namespace>
```

2. **Helm delete**

```shell
helm delete flowmanager-mongodb --namespace=<your_namespace>
```

### Internal Redis on Kubernetes

**Caution internal redis will be not encrypted with certificate. [Redis.yaml](kubernetes/base/redis.yaml) has to be configured.**

1. **Helm deployment/upgrade**

```shell
helm upgrade --install flowmanager-redis -f redis.yaml bitnami/redis --version 14.8.8 --namespace=<your_namespace>
```

2. **Helm delete**

```shell
helm delete flowmanager-redis --namespace=<your_namespace>
```
