#! /bin/bash


#DO NOT DELETE/EDIT/CHANGE/TOUCH THIS
DEPLOY_TOKEN="A266_wFxgY58M-uqM8DT"

rm -rf Docker-FlowCentral

git config --global http.sslverify "false"

# Cloning the flowcentral repository
git clone http://gitlab+deploy-token-15:$DEPLOY_TOKEN@git.ecd.axway.int/flowcentral/flowcentral-internal.git $PWD/Docker-FlowCentral

cd Docker-FlowCentral

mkdir -p ./mounts/configs
mkdir -p ./mounts/fc_logs
mkdir -p ./mounts/fc_keys
mkdir -p ./mounts/fc_resources
mkdir -p ./mounts/fc_plugins

mkdir -p ./mounts/mongo_data
mkdir -p ./mounts/mongo_certificates
mkdir -p ./mounts/mongo_config

chmod -R 777 $PWD/mounts/
chmod 777 mongo_3.6/*.sh 

cp ./licenses/*.jks "$PWD/mounts/configs"
cp ./licenses/*.pem "$PWD/mounts/configs"
cp ./licenses/license.xml "$PWD/mounts/configs"

cp ./mongo_3.6/resources/ssl/*.pem "$PWD/mounts/mongo_certificates/"
