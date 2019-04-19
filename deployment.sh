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
mkdir -p ./mounts/mongo_data

chmod -R 777 $PWD/mounts/
chmod 777 mongo-3.4/*.sh 

unzip -o licenses/apic.z_i_p -d $PWD/mounts/configs && rm -rf $PWD/mounts/configs/*.der

cp ./licenses/*.jks "$PWD/mounts/configs" && rm -rf "$PWD/mounts/configs/truststore.jks" && rm -rf "$PWD/mounts/configs/keycloak.jks"

cp ./licenses/license.xml "$PWD/mounts/configs"