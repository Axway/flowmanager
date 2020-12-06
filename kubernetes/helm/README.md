# Flowmanager Deployment on Kubernetes

## Prerequisites

  - [yq 3.0+](https://github.com/mikefarah/yq)
  - Kubernetes 1.14+
  - Helm 2.16+
  - Helm 3+ 

## Introduction

Content of this folder :
* [Flowmanager deployment](flowmanager/README.md)
* [Mongodb deployment](mongodb/README.md)
* [Redis deployment](redis-ha/README.md)

**Caution for redis and mongodb you need to accept the usage of external docker images not under Axway responsability.**

### Internal Mongodb on Kubernetes 

**Caution internal mongodb will be not encrypted with certificate**

1. **Please choose between 1 or 3 nodes installation**

    - mongodb-1node
        - Changing the default values file in [mongodb-1node.yaml](mongodb-1node.yaml)
    - mongodb-3nodes
        - Changing the default values file in [mongodb-3nodes.yaml](mongodb-3nodes.yaml)

2. **Helm deployment**

* 1 Node
```console
$ helm install  flowmanager-mongodb ./mongodb space=<your_namespace> -f mongodb-1node.yaml
```
* 3 Nodes
```console
$ helm install  flowmanager-mongodb ./mongodb space=<your_namespace> -f mongodb-3nodes.yaml
```

3. **Helm update**

```console
$ helm upgrade --install flowmanager-mongodb ./mongodb space=<your_namespace> -f your_values_file.yaml
```

4. **Helm delete**

```console
$ helm delete flowmanager-mongodb space=<your_namespace> 
```

### Internal Redis on Kubernetes 

**Caution internal redis will be not encrypted with certificate**

1. **Please choose between 1 or 3 nodes installation**

    - redis-1node
        - Changing the default values file in [redis-1node.yaml](redis-1node.yaml)
    - redis-3nodes
        - Changing the default values file in [redis-3nodes.yaml](redis-3nodes.yaml)

2. **Helm deployment**

* 1 Node
```console
$ helm install  flowmanager-redis ./redis-ha space=<your_namespace> -f redis-1node.yaml
```
* 3 Nodes
```console
$ helm install  flowmanager-redis ./redis-ha space=<your_namespace> -f redis-3nodes.yaml
```

3. **Helm update**

```console
$ helm upgrade --install flowmanager-redis ./redis-ha space=<your_namespace> -f your_values_file.yaml
```

4. **Helm delete**

```console
$ helm delete flowmanager-redis space=<your_namespace> 
```

### Flowmanager

1. **Helm deployment**

```console
$ helm install  flowmanager ./flowmanager space=<your_namespace> -f flowmanager.yaml
```

3. **Helm update**

```console
$ helm upgrade --install flowmanager ./flowmanager space=<your_namespace> -f your_values_file.yaml
```

4. **Helm delete**

```console
$ helm delete flowmanager space=<your_namespace> 
```