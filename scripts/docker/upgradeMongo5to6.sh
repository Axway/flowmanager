#!/bin/bash

set -euo pipefail

ROOT_DB_USER="root"
ROOT_DB_PASS="root_pass"

echo "Please enter the user name of the root user of the database:"
read -r ROOT_DB_USER
echo "Please enter the password of the root user of the database:"
read -r -s ROOT_DB_PASS

if [ ! -f ../../docker-compose/docker-compose.yml ]; then
    echo "docker-compose.yml not found!"
    exit 1
fi

cd ../../docker-compose/
docker compose down
sed -i "s/MONGO_IMAGE_VERSION:-5.0/MONGO_IMAGE_VERSION:-6.0/g" ./docker-compose.yml
docker compose up -d
while [ "$(docker inspect -f {{.State.Health.Status}} docker-compose-mongodb-1)" != "healthy" ]; do  sleep 2; echo "Waiting for mongo.."; done
docker exec -it docker-compose-mongodb-1 bash -c "mongosh -u $ROOT_DB_USER -p $ROOT_DB_PASS --eval \"db.adminCommand( {setFeatureCompatibilityVersion: '6.0' } )\""

echo "MongoDB was upgraded to 6.0!"
