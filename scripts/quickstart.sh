#! /bin/bash

if [ ! -f ./docker-compose.yml ]; then
    echo "You should launch this script from root dir as ./scripts/quickstart.sh"
    exit 1
fi

if [ -z "$1" ]; then
    echo "No argument supplied. Please supply the path towards the license file and provide the necessary permissions."
    exit 0
fi

mkdir -p ./mounts/configs
mkdir -p ./mounts/fc_logs
mkdir -p ./mounts/fc_keys
mkdir -p ./mounts/fc_plugins
mkdir -p ./mounts/fc_resources
mkdir -p ./mounts/mongo_data
mkdir -p ./mounts/mongo_certificates
mkdir -p ./mounts/mongo_config

chmod 777 -R ./mounts

if [[ -f "$1" ]]; then
	cp $1 ./mounts/configs
else 
	echo "The license file does not exist, please check the file permissions and run the script again with the correct path."
fi

./scripts/gen-amplify-certs.sh
./scripts/gen-certs.sh
