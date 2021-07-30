#!/usr/bin/env bash

echo 'Creating application user, pass and db'

# Create application user
mongo ${MONGO_APP_DATABASE} \
        --host localhost \
        --port ${MONGO_INTERNAL_PORT} \
        -u ${MONGO_INITDB_ROOT_USERNAME} \
        -p ${MONGO_INITDB_ROOT_PASSWORD} \
        --authenticationDatabase admin \
        --eval "db.createUser({user:'${MONGO_APP_USER}', pwd:'${MONGO_APP_PASS}', roles:[{role:'dbOwner', db:'${MONGO_APP_DATABASE}'}]});"
