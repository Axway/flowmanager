#/bin/bash

if [ ! -f ../docker-compose/docker-compose.yml ]; then
    echo "docker-compose.yml not found!"
    exit 1
fi

cd ../docker-compose/
docker-compose  down
sed -i "s/MONGO_IMAGE_VERSION:-3.6/MONGO_IMAGE_VERSION:-4.0/g" ./docker-compose.yml
docker-compose up -d mongodb
sleep 15
docker exec -it docker-compose_mongodb_1 bash -c 'mongo -uroot -p rootpassword --eval "db.adminCommand( {setFeatureCompatibilityVersion: \"4.0\" } )"'
docker-compose down mongodb
sed -i "s/MONGO_IMAGE_VERSION:-4.0/MONGO_IMAGE_VERSION:-4.2/g" ./docker-compose.yml
docker-compose up -d

echo "Done, your mongo was upgraded to 4.2!"
