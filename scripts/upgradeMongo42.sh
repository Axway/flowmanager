#!/bin/bash

ROOT_DB_USER="root"
ROOT_DB_PASS="root_pass"

echo "Please enter the user name of the root user of the database:"
read ROOT_DB_USER
echo "Please enter the password of the root user of the database:"
read -s ROOT_DB_PASS

if [ ! -f ../docker-compose/docker-compose.yml ]; then
    echo "docker-compose.yml not found!"
    exit 1
fi

cd ../docker-compose/
docker-compose  down
sed -i "s/MONGO_IMAGE_VERSION:-3.6/MONGO_IMAGE_VERSION:-4.0/g" ./docker-compose.yml
docker-compose up -d mongodb
while [ "`docker inspect -f {{.State.Health.Status}} docker-compose_mongodb_1`" != "healthy" ]; do  sleep 2; echo "Waiting for mongo.."; done
docker exec -it docker-compose_mongodb_1 bash -c 'mongo -u ROOT_DB_USER -p ROOT_DB_PASS --eval "db.adminCommand( {setFeatureCompatibilityVersion: \"4.0\" } )"'
docker-compose down
sed -i "s/MONGO_IMAGE_VERSION:-4.0/MONGO_IMAGE_VERSION:-4.2/g" ./docker-compose.yml
docker-compose up -d

echo "Done, your mongo was upgraded to 4.2!"
