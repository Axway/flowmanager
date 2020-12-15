# Deploy using standard files

Deploy using standard Kubernetes deployment manifest files.

## Requirements

* kubectl
* Customer certificates and password
* Secret for pulling docker image (Optional)
* Customer License (`license.xml`)
* Mongodb URL
* `user` and `password` for Mongodb

## ***Setup & Run***

## How to create secrets for certificates

* License
```console
$ kubectl create secret generic flowmanager-license --from-file=license.xml
```

* UI
```console
$ kubectl create secret generic flowmanager-httpskeystore --from-file=uicert.p12
```

* Governance
```console
$ kubectl create secret generic flowmanager-governance --from-file=governanceca.p12
```

_**Warning:** Each files used from this step we need to be update the [Deployment file](flowmanager/deployment.yaml)_

## How to create secrets for monogdb credentials or redis

Inside the file [secret-env.yml](standard/base/secret-env.yml)

Updating each values for the keys related:
```
  FM_GENERAL_ENCRYPTION_KEY: ""
  FM_HTTPS_KEYSTORE_PASSWORD: ""
  FM_CFT_SHARED_SECRET: ""
  FM_DATABASE_USER_NAME: ""
  FM_DATABASE_USER_PASSWORD: ""
  FM_GOVERNANCE_CA_PASSWORD: ""
```

Example with mongodb user/password:
```console
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

## How to configure Flowmanager before deployment

Files to check and modify :
* Deployment file: SingleNode(singlenode/patch.yml) or MultiNode(multinode/patch.yml)
* [Secret Env file](base/secret-env.yml)

# How to deploy Flowmanager

> Hack, it is possible to get all fields on going to be changed, with a searching based on the word `MUST` inside the file

**This stuff permit to deploy only Flowmanager 1 node**

1. Creating manually all secrets for the licence and certificates
2. Editing manually the yaml file for parameters needed or madatory for the customer
3. Applying all the files
ex:
```console
$ kubectl apply -k ./singlenode
```

## ***Remove***

kubectl delete -k ./singlenode
