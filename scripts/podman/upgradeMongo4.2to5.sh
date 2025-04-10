#!/bin/bash

set -euo pipefail

ROOT_DB_USER="root"
ROOT_DB_PASS="root_pass"

echo "Please enter the user name of the root user of the database:"
read -r ROOT_DB_USER
echo "Please enter the password of the root user of the database:"
read -r -s ROOT_DB_PASS

if [ ! -f ../../podman/flowmanager.yml ]; then
    echo "flowmanager.yml not found!"
    exit 1
fi

cd ../../podman/
podman exec -it flowmanager_pod-mongodb bash -c "mongo -u $ROOT_DB_USER -p $ROOT_DB_PASS --eval \"db.adminCommand( {setFeatureCompatibilityVersion: '4.2'} )\""
podman pod rm -f flowmanager_pod
sed -i "s/mongo:4.2/mongo:4.4/g" ./flowmanager.yml
podman play kube ./flowmanager.yml

echo "Waiting for mongo.."
sleep 30

podman exec -it flowmanager_pod-mongodb bash -c "mongo -u $ROOT_DB_USER -p $ROOT_DB_PASS --eval \"db.adminCommand( {setFeatureCompatibilityVersion: '4.4'} )\""
podman pod rm -f flowmanager_pod
sed -i "s/mongo:4.4/mongo:5.0/g" ./flowmanager.yml
podman play kube ./flowmanager.yml

echo "Waiting for mongo.."
sleep 30

podman exec -it flowmanager_pod-mongodb bash -c "mongosh -u $ROOT_DB_USER -p $ROOT_DB_PASS --eval \"db.adminCommand( {setFeatureCompatibilityVersion: '5.0'} )\""

echo "MongoDB was upgraded to 5.0!"
