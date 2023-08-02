## Installation steps for Kubernetes with Standard Manifest Files using flowmanager_helper.sh

### Prerequisites  

* Kubernetes 1.17 and higher
* Helm 3+ (only for Mongo)
* Customer license and certificates
* Mongodb 4.2 (can be installed with flowmanager_helper.sh -m)
* Nginx 1.15 and higher, installed and configured for Ingress usage
* SSL certificate

### Steps  

#### 1. Install Mongodb (if needed) 

1. Customize mongodb.yaml according to your needs. The user and password are mandatory to be changed.
2. Install MongoDB using (Helm required)
```shell
./flowmanager_helper.sh -m  for MongoDB  (Kubernetes)
./flowmanager_helper.sh -mo  for MongoDB  (OpenShift)
```

#### 2. Create a service account

1. Log in to the Amplify Platform.
2. Select your organization, and from the left menu, click Service Accounts (You should see all service accounts already created).
3. Click + Service Account, and fill in the mandatory fields:
4. Enter a name for the service account.
5. Choose Client Secret for the method.
6. Choose Platform-generated secret for the credentials.
7. Click Save
8. Ensure to securely store the generated client secret because it will be required in further steps.

#### 3.Create kubernetes docker registry secret:
```shell
   kubectl create secret docker-registry regcred --docker-server=docker.repository.axway.com --docker-username=<SERVICE_ACCOUNT> --docker-password=<PASSWORD> -n <NAMESPACE>
```   
For OpenShift clusters, replace _kubectl_ with _oc_.

#### 4. Create secrets enviroment variables

Customize [patch.yml](./multinode/patch.yml) for Flow Manager Multi-Node and/or [patch.yml](./singlenode/patch.yml) for Flow Manager SingleNode with your secrets enviroment variables: 

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

#### 5. Create license secret

Copy your license to the [root folder](./) or run the following command in order to create the secret:
   ```shell
   kubectl create secret generic license --from-file=license.xml -n <NAMESPACE>
   ```
   For OpenShift clusters, replace _kubectl_ with _oc_.

#### 6. Create secrets

Generate the certificates and secrets using:
```shell
./flowmanager_helper.sh -gc (Kubernetes)
./flowmanager_helper.sh -gco (OpenShift)
```

or:    

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
```

#### 7. Create TLS secret

```shell
kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>
```

#### 8. Customize patch.yaml

Customize [patch.yml](./multinode/patch.yml) and [ingress.yml](./multinode/ingress.yml) for FM MultiNode and/or [patch.yml](./singlenode/patch.yml) and [ingress.yml](./singlenode/ingress.yml) for FM SingleNode. You can add and remove any parameter from patch.yml, please check [docs](/docs/).

#### 9. Install Flow Manager


- Using flowmanager_helper.sh (only for Kubernetes clusters):
```shell
./flowmanager_helper.sh -fm-s  for FM SingleNode
./flowmanager_helper.sh -fm-m  for FM MultiNode  
./flowmanager_helper.sh -fm-s  for FM SingleNode
```

- Using standard commands:

```shell
kubectl apply -k ./singlenode -n <namespace> for FM SingleNode(Kubernetes cluster)
kubectl apply -k ./multinode -n <namespace> for FM MultiNode(Kubernetes cluster)
oc apply -f ./singlenode -n <namespace> for FM SingleNode(OpenShift cluster)  
oc apply -f ./multinode -n <namespace>  for FM MultiNode(OpenShift cluster)  
```
