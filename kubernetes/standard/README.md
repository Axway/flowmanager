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

Inside the file [secret-env.yaml](standard/base/secret-env.yaml)

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

## ***Upgrade***

## ***Remove***
