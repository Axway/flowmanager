#!/usr/bin/bash

#Setting PATH
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin

#Cluster variables
CLUSTER_REGION=ap-southeast-2
CLUSTER_NAME=cbafm-dev-fm
CLUSTER_ROLE_ARN=arn:aws:iam::REPLACE
KUBE_CONTEXT=arn:aws:eks:REPLACE

#Mongodb Variables
MONGODB_NAMESPACE=flowmanager
MONGO_DB_POD=mft-mongodb-release-0
LOCAL_BACKUP_PATH=/tmp/fm_mongo_backup

#S3 variables
BUCKET_NAME=REPLACE-mongodb-backups
CURRENT_DATE=$(date +%Y-%m-%d)
BACKUP_PREFIX=daily

#Connect to cluster
aws --region $CLUSTER_REGION eks update-kubeconfig --name $CLUSTER_NAME --role-arn $CLUSTER_ROLE_ARN
kubectl config use-context $KUBE_CONTEXT

#Performing mongodump and copying on local machine
MONGODB_ROOT_PASSWORD=$(kubectl get secrets/mongodb-secret-env-vars -n $MONGODB_NAMESPACE --template='{{index .data "mongodb-root-password"}}' | base64 -d)
kubectl exec -it $MONGO_DB_POD -n $MONGODB_NAMESPACE -- /bin/bash -c "mongodump --ssl --sslCAFile=/certs/mongodb-ca-cert --sslPEMKeyFile=/certs/mongodb.pem --authenticationDatabase=admin -u root -p $MONGODB_ROOT_PASSWORD -o /tmp/"
kubectl cp -n $MONGODB_NAMESPACE $MONGO_DB_POD:/tmp/ $LOCAL_BACKUP_PATH

#Delete backup from mongo pod
kubectl exec -it $MONGO_DB_POD -n $MONGODB_NAMESPACE -- /bin/bash -c "rm -rf /tmp/umcft /tmp/stplugin /tmp/admin /tmp/config"

#Copying mongodb backup to S3 bucket
aws s3 sync $LOCAL_BACKUP_PATH s3://$BUCKET_NAME/$BACKUP_PREFIX/$BACKUP_PREFIX-$CURRENT_DATE/

#Delete from local path
rm -rf $LOCAL_BACKUP_PATH