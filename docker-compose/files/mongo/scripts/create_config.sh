#!/usr/bin/env bash

# Define the variables used later in config file
TEMPLATE_CONFIG_PATH="/docker-entrypoint-initdb.d"

# Custom config
if [ -z $MONGO_BIND_IP ]; then
    BIND_IP="0.0.0.0"
else
    BIND_IP=$MONGO_BIND_IP
fi

if [ -z $MONGO_CA_FILE ] && [ -z $MONGO_PEM_KEY_FILE ]; then
    ALLOW_CONNECTIONS_WITHOUT_CERTIFICATES=true
else
    ALLOW_CONNECTIONS_WITHOUT_CERTIFICATES=false
    CA=$MONGO_CA_FILE
    PEM=$MONGO_PEM_KEY_FILE
fi

function render_template() {
  eval "echo \"$(cat $1)\""
}

function generate_conf {
  echo "Creating mongod.conf file..."
  render_template $TEMPLATE_CONFIG_PATH/mongod.tmpl > /tmp/mongod.conf
}

generate_conf
