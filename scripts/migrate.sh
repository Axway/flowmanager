#!/bin/bash

if [ ! -f ../docker-compose/docker-compose.yml ]; then
    echo "docker-compose.yml not found!"
    exit 1
fi

cd ../docker-compose/

OLD_PATH=""

echo "Please enter the path of the folder that contains the old docker-compose.yml file:"
read OLD_PATH

echo "Generating the .env file..."

echo "FLOWMANAGER_VERSION=\"\"" > .env 
ACCEPT_EULA=\"$(yq -e e '.services.flowmanager.environment.ACCEPT_EULA' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "ACCEPT_EULA=$ACCEPT_EULA" >> .env
FM_GENERAL_FQDN=\"$(yq -e e '.services.flowmanager.environment.FM_GENERAL_FQDN' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_GENERAL_FQDN=$FM_GENERAL_FQDN" >> .env
FM_GENERAL_UI_PORT=\"$(yq -e e '.services.flowmanager.environment.FM_GENERAL_UI_PORT' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_GENERAL_UI_PORT=$FM_GENERAL_UI_PORT" >> .env
FM_GENERAL_ENCRYPTION_KEY=\"$(yq -e e '.services.flowmanager.environment.FM_GENERAL_ENCRYPTION_KEY' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_GENERAL_ENCRYPTION_KEY=$FM_GENERAL_ENCRYPTION_KEY" >> .env
FM_LOGS_CONSOLE=\"$(yq -e e '.services.flowmanager.environment.FM_LOGS_CONSOLE' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_LOGS_CONSOLE=$FM_LOGS_CONSOLE" >> .env
FM_GENERAL_LOGGING_LEVEL=\"$(yq -e e '.services.flowmanager.environment.FM_GENERAL_LOGGING_LEVEL' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_GENERAL_LOGGING_LEVEL=$FM_GENERAL_LOGGING_LEVEL" >> .env
FM_GOVERNANCE_CA_FILE=\"$(yq -e e '.services.flowmanager.environment.FM_GOVERNANCE_CA_FILE' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_GOVERNANCE_CA_FILE=$FM_GOVERNANCE_CA_FILE" >> .env
FM_GOVERNANCE_CA_PASSWORD=\"$(yq -e e '.services.flowmanager.environment.FM_GOVERNANCE_CA_PASSWORD' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_GOVERNANCE_CA_PASSWORD=$FM_GOVERNANCE_CA_PASSWORD" >> .env
FM_HTTPS_USE_CUSTOM_CERT=\"$(yq -e e '.services.flowmanager.environment.FM_HTTPS_USE_CUSTOM_CERT' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_HTTPS_USE_CUSTOM_CERT=$FM_HTTPS_USE_CUSTOM_CERT" >> .env
FM_HTTPS_KEYSTORE=\"$(yq -e e '.services.flowmanager.environment.FM_HTTPS_KEYSTORE' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_HTTPS_KEYSTORE=$FM_HTTPS_KEYSTORE" >> .env
FM_HTTPS_KEYSTORE_PASSWORD=\"$(yq -e e '.services.flowmanager.environment.FM_HTTPS_KEYSTORE_PASSWORD' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_HTTPS_KEYSTORE_PASSWORD=$FM_HTTPS_KEYSTORE_PASSWORD" >> .env
FM_DATABASE_USER_NAME=\"$(yq -e e '.services.flowmanager.environment.FM_DATABASE_USER_NAME' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_DATABASE_USER_NAME=$FM_DATABASE_USER_NAME" >> .env
FM_DATABASE_USER_PASSWORD=\"$(yq -e e '.services.flowmanager.environment.FM_DATABASE_USER_PASSWORD' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_DATABASE_USER_PASSWORD=$FM_DATABASE_USER_PASSWORD" >> .env
FM_DATABASE_NAME=\"$(yq -e e '.services.fmmongo.environment.MONGODB_APPLICATION_DATABASE' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_DATABASE_NAME=$FM_DATABASE_NAME" >> .env
FM_DATABASE_USE_SSL=\"$(yq -e e '.services.flowmanager.environment.FM_DATABASE_USE_SSL' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_DATABASE_USE_SSL=$FM_DATABASE_USE_SSL" >> .env
FM_DATABASE_CERTIFICATES=\"$(yq -e e '.services.flowmanager.environment.FM_DATABASE_CERTIFICATES' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_DATABASE_CERTIFICATES=$FM_DATABASE_CERTIFICATES" >> .env
FM_JVM_XMX=\"$(yq -e e '.services.flowmanager.environment.FM_JVM_XMX' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_JVM_XMX=$FM_JVM_XMX" >> .env
FM_JVM_XMS=\"$(yq -e e '.services.flowmanager.environment.FM_JVM_XMS' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_JVM_XMS=$FM_JVM_XMS" >> .env
FM_JVM_XMN=\"$(yq -e e '.services.flowmanager.environment.FM_JVM_XMN' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "FM_JVM_XMN=$FM_JVM_XMN" >> .env
echo "FM_CFT_UPDATES_PATH=\"/opt/axway/FlowManager/updates/cft/\"" >> .env
echo "FM_ST_PLUGIN_CA_FILE=\"/opt/axway/FlowManager/st-fm-plugin/st-fm-plugin-ca.pem\"" >> .env
echo "FM_ST_PLUGIN_PUBLIC_KEY=\"/opt/axway/FlowManager/st-fm-plugin/public-key\"" >> .env

MONGO_INITDB_ROOT_USERNAME=\"$(yq -e e '.services.fmmongo.environment.MONGODB_ADMIN_USER' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "MONGO_INITDB_ROOT_USERNAME=$MONGO_INITDB_ROOT_USERNAME" >> .env
MONGO_INITDB_ROOT_PASSWORD=\"$(yq -e e '.services.fmmongo.environment.MONGODB_ADMIN_PASS' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "MONGO_INITDB_ROOT_PASSWORD=$MONGO_INITDB_ROOT_PASSWORD" >> .env
MONGO_APP_DATABASE=\"$(yq -e e '.services.fmmongo.environment.MONGODB_APPLICATION_DATABASE' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "MONGO_APP_DATABASE=$MONGO_APP_DATABASE" >> .env
MONGO_APP_USER=\"$(yq -e e '.services.fmmongo.environment.MONGODB_APPLICATION_USER' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "MONGO_APP_USER=$MONGO_APP_USER" >> .env
MONGO_APP_PASS=\"$(yq -e e '.services.fmmongo.environment.MONGODB_APPLICATION_PASS' $OLD_PATH/docker-compose.yml 2>/dev/null)\" && echo "MONGO_APP_PASS=$MONGO_APP_PASS" >> .env
echo "MONGO_CA_FILE=\"\"" >> .env
echo "MONGO_PEM_KEY_FILE=\"\"" >> .env
MONGO_INTERNAL_PORT=\"$(yq -e e '.services.fmmongo.environment.MONGODB_PORT' $OLD_PATH/docker-compose.yml 2>/dev/null)\"
echo "MONGO_IMAGE_VERSION=\"3.6\"" >> .env

echo "ST_FM_PLUGIN_IMAGE_VERSION=\"\"" >> .env
echo "ST_FM_PLUGIN_ST_SKIP_HOSTNAME_VERIFICATION=\"true\"" >> .env
echo "ST_FM_PLUGIN_FM_FQDN=\"flowmanager\"" >> .env
echo "ST_FM_PLUGIN_FM_DEPLOYMENT_MODE=\"premise\"" >> .env
echo "ST_FM_PLUGIN_SHARED_SECRET=\"/usr/src/app/src/st-fm-plugin-shared-secret\"" >> .env
echo "ST_FM_PLUGIN_FM_GOV_CA_FULL_CHAIN=\"/usr/src/app/src/governanceca.pem\"" >> .env
echo "ST_FM_PLUGIN_SERVER_PRIVATE_KEY_PEM=\"/usr/src/app/src/st-fm-plugin-cert-key.pem\"" >> .env
echo "ST_FM_PLUGIN_CERT_PEM=\"/usr/src/app/src/st-fm-plugin-cert.pem\"" >> .env
echo "ST_FM_PLUGIN_SERVER_CA_FULL_CHAIN=\"/usr/src/app/src/st-fm-plugin-ca.pem\"" >> .env
echo "ST_FM_PLUGIN_JWT_KEY=\"/usr/src/app/src/private-key\"" >> .env
echo "ST_FM_PLUGIN_REJECT_UNAUTHORIZED_CONNECTION=\"true\"" >> .env
echo "ST_FM_PLUGIN_DATABASE_NAME=$MONGO_APP_DATABASE" >> .env
echo "ST_FM_PLUGIN_DATABASE_USER_NAME=$MONGO_APP_USER" >> .env
echo "ST_FM_PLUGIN_DATABASE_USER_PASSWORD=$MONGO_APP_PASS" >> .env
echo "ST_FM_PLUGIN_DATABASE_CERTIFICATES=\"\"" >> .env

echo "Dump the old Mongo database"
docker-compose -f $OLD_PATH/docker-compose.yml exec -T fmmongo mongodump --archive -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --port $MONGO_INTERNAL_PORT > db.dump

echo "Start the new Mongo database"
docker-compose up -d mongodb
while [ "`docker inspect -f {{.State.Health.Status}} docker-compose_mongodb_1`" != "healthy" ]; do  sleep 2; echo "Waiting for the new Mongo database to start up..."; done
echo "Mongo database started. Importing Mongo dump..."
docker-compose exec -T mongodb mongorestore --archive -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --drop < db.dump

echo "Stopping the new Mongo database..."
docker-compose down

echo "Migration completed successfully!"