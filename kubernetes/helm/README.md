# Flowmanager Deployment on Kubernetes with Helm Charts

## Prerequisites

* Kubernetes 1.17+
* Helm 3+
* Customer license
* Mongodb
* Redis (only for Flowmanager Multinode)
* Nginx 1.15 and higher, installed and configured for Ingress usage
* SSL certificate

## Content

### 1. Install Mongodb/Redis (if needed) 

1. Customize mongodb.yaml and redis.yaml according to your needs. The user and password are mandatory to be changed.
2. Install Redis and/or MongoDB using
```shell
./flowmanager_helper.sh -m  for MongoDB  (Kubernetes)
./flowmanager_helper.sh -r  for Redis    (Kubernetes)
./flowmanager_helper.sh -mo  for MongoDB  (OpenShift)
./flowmanager_helper.sh -ro  for Redis    (OpenShift)
```

### 2. Create a service account

1. Log in to the Amplify Platform.
2. Select your organization, and from the left menu, click Service Accounts (You should see all service accounts already created).
3. Click + Service Account, and fill in the mandatory fields:
4. Enter a name for the service account.
5. Choose Client Secret for the method.
6. Choose Platform-generated secret for the credentials.
7. Click Save
8. Ensure to securely store the generated client secret because it will be required in further steps.

### 3. Deployment

There are two ways to deploy Flow Manager:

- automated deployment
- manual deployment

#### Automated deployment

1. Create the TLS secret for your domain:
   >``` kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>```  
   For OpenShift clusters, replace _kubectl_ with _oc_.
2. Copy your license to the [root folder](/kubernetes/) or run the following command in order to create the secret:
   >```kubectl create secret generic license --from-file=license.xml -n <NAMESPACE>```  
   For OpenShift clusters, replace _kubectl_ with _oc_.
3. Generate the certificates and secrets using:
   >```./flowmanager_helper.sh -gc``` (Kubernetes)  
   >```./flowmanager_helper.sh -gco``` (OpenShift) 
4. Customize [flowmanager.yaml](/kubernetes/helm/flowmanager.yaml). You can add and remove any parameter from flowmanager.yaml, please check [docs](/docs/).
5. Install Flow Manager using Helm Charts:
   >```./flowmanager_helper.sh -fm-h ``` (Kubernetes)    
   >```./flowmanager_helper.sh -fm-ho ```(OpenShift)

#### Manual deployment

1. Create kubernetes secrets:
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
For OpenShift clusters, replace _kubectl_ with _oc_.

2. Create kubernetes TLS secret:
 >```kubectl create secret tls tls --cert=path/to/cert/file --key=path/to/key/file -n <NAMESPACE>```  
For OpenShift clusters, replace _kubectl_ with _oc_.

3. Create kubernetes docker registry secret:
>```kubectl create secret docker-registry regcred --docker-server=docker.repository.axway.com --docker-username=<SERVICE_ACCOUNT> --docker-password=<PASSWORD> -n <NAMESPACE>```   
For OpenShift clusters, replace _kubectl_ with _oc_.

4. Pull helm chart:
>```helm repo add axway https://helm.repository.axway.com --username <SERVICE_ACCOUNT> --password <PASSWORD>```
>```helm pull axway/flowmanager-helm-prod-buch-flowmanager```

5. Customize [flowmanager.yaml](/kubernetes/helm/flowmanager.yaml). You can add and remove any parameter from flowmanager.yaml, please check [docs](/docs/).

6. Install the chart:
>```helm install flowmanager axway/flowmanager-helm-prod-buch-flowmanager --values flowmanager.yaml -n <NAMESPACE>```

