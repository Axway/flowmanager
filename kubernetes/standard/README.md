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

_**Warning:** Each files used from this step we need to be update the [Deployment file](base/deployment.yaml)_


## ***Upgrade***

## ***Remove***
