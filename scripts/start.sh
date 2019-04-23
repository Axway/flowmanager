#!/bin/bash
set -euo pipefail
ACCEPT_EULA="${ACCEPT_EULA:-no}"

if [[ $ACCEPT_EULA = "yes" ]]; then
	echo "You have accepted the EULA, the configuration will proceed as normal."
else
	echo "You have not accepted the EULA, please accept it otherwise the configuration will not proceed. Exiting now."
	exit 1
fi

GENERAL_UI_PORT="${GENERAL_UI_PORT:-8081}"
GENERAL_LOGGING_LEVEL="${GENERAL_LOGGING_LEVEL:-INFO}"
GENERAL_REGISTRATION_APPROVAL="${GENERAL_REGISTRATION_APPROVAL:-false}"
GENERAL_SMTP_HOST="${GENERAL_SMTP_HOST:-localhost}"
GENERAL_SMTP_PORT="${GENERAL_SMTP_PORT:-25}"
CFT_USE_APP_FOR_PARTNER_ID="${CFT_USE_APP_FOR_PARTNER_ID:-true}"
CERTIFICATE_EXPIRATION_NOTIFICATION="${CERTIFICATE_EXPIRATION_NOTIFICATION:-60}"
HTTPS_KEYSTORE_PASSWORD="${HTTPS_KEYSTORE_PASSWORD:-Secret01}"

subst() {
     sed -i 's#'$1'.*#'$1'='$2'#g' /opt/axway/FlowCentral/conf.properties
}

function get_current_field_value() {
  CURRENT_FIELD_VALUE=$(cat /opt/axway/FlowCentral/conf.properties | grep "$1" | cut -d '=' -f2 | sed 's/"//g')
}


function monitor_log() {
  echo >/opt/axway/monitored
  local new=""
  while true; do
    new=""
    (find /opt/axway/fc_logs/ -name "*.log" -o -name "*.log.0" || echo "") | while read file; do
      if ! grep "$file" /opt/axway/monitored >/dev/null; then
        echo $file >> /opt/axway/monitored;
        new="$new $file"
        tail -F $file | awk '{print "'"[$(basename "$file")] "'"$0}'&
      fi
    done
    if [ ! -z "$new" ]; then
      echo "[LOG MONITORING] $new"
    fi
    sleep 5
  done
}


monitor_log &

if [ ! -f /opt/axway/FlowCentral/runtime/initialized ]; then
  cp /opt/axway/resources/conf_to_import.txt /opt/axway/FlowCentral/conf.properties 
  #General
  subst GENERAL_FQDN ${FQDN}
  subst GENERAL_HOSTNAME ${HOSTNAME}
  # subst GENERAL_UI_PORT ${GENERAL_UI_PORT}
  # subst GENERAL_MAX_RETRIES_DB_CONN ${GENERAL_MAX_RETRIES_DB_CONN}
  subst GENERAL_ENCRYPTION_KEY ${GENERAL_ENCRYPTION_KEY}
  subst GENERAL_LOGGING_LEVEL ${GENERAL_LOGGING_LEVEL}
  # subst GENERAL_REGISTRATION_APPROVAL ${GENERAL_REGISTRATION_APPROVAL}
  # subst GENERAL_SMTP_HOST ${GENERAL_SMTP_HOST}
  # subst GENERAL_SMTP_PORT ${GENERAL_SMTP_PORT}
  # subst GENERAL_LICENSE ${GENERAL_LICENSE}
  # subst GENERAL_DB_IGNORE ${GENERAL_DB_IGNORE}
  # subst GENERAL_CUSTOM_LOCATION_ENABLED ${GENERAL_CUSTOM_LOCATION_ENABLED}
  # subst GENERAL_CUSTOM_LOCATION_PATH ${GENERAL_CUSTOM_LOCATION_PATH}
  # subst GENERAL_DERIVED_KEY_ROOT_FOLDER ${GENERAL_DERIVED_KEY_ROOT_FOLDER}

  #HTTPS
  subst HTTPS_USE_CUSTOM_CERT ${HTTPS_USE_CUSTOM_CERT}
  subst HTTPS_KEYSTORE ${HTTPS_KEYSTORE}
  subst HTTPS_CERT_ALIAS ${HTTPS_CERT_ALIAS}
  subst HTTPS_KEYSTORE_PASSWORD ${HTTPS_KEYSTORE_PASSWORD}
  # subst HTTPS_CORS ${HTTPS_CORS}

  #CERTIFICATE
  subst CERTIFICATE_EXPIRATION_NOTIFICATION ${CERTIFICATE_EXPIRATION_NOTIFICATION}

  #IDP
  # subst IDP_CONFIGURATION ${IDP_CONFIGURATION}

  #APIC
  subst APIC_HOST ${APIC_HOST}
  subst APIC_CLIENTID ${APIC_CLIENTID}
  subst APIC_PUBLICKEY ${APIC_PUBLICKEY}
  subst APIC_PRIVATEKEY ${APIC_PRIVATEKEY}
  subst APIC_USE_CATALOG ${APIC_USE_CATALOG}
  subst APIC_TOKENURL ${APIC_TOKENURL}

  #Mongo
  subst MONGODB_HOST ${MONGODB_HOST}
  subst MONGODB_PORT ${MONGODB_PORT}
  subst MONGODB_USER_NAME ${MONGODB_USER_NAME}
  subst MONGODB_USER_PASSWORD ${MONGODB_USER_PASSWORD}

  #Business
  subst BUSINESS_CA_CERTIF_ALIAS ${BUSINESS_CA_CERTIF_ALIAS}
  subst BUSINESS_CA_FILE ${BUSINESS_CA_FILE}
  subst BUSINESS_CA_PASSWORD ${BUSINESS_CA_PASSWORD}

  #GOVERNANCE
  subst GOVERNANCE_CA_CERTIF_ALIAS ${GOVERNANCE_CA_CERTIF_ALIAS}
  subst GOVERNANCE_CA_FILE ${GOVERNANCE_CA_FILE}
  subst GOVERNANCE_CA_PASSWORD ${GOVERNANCE_CA_PASSWORD}

  #CFT
  subst CFT_SHARED_SECRET ${CFT_SHARED_SECRET}
  # subst CFT_USE_APP_FOR_PARTNER_ID ${CFT_USE_APP_FOR_PARTNER_ID}
  # subst CFT_USE_LEGACY_AM_WRAPPER ${CFT_USE_LEGACY_AM_WRAPPER}

  
  cd /opt/axway/FlowCentral
  cat /opt/axway/FlowCentral/conf.properties
  echo "Configuring Product Starting"
  time java -jar opcmd.jar configure -s /opt/axway/FlowCentral/conf.properties -n
  echo "Configuring Product Ended"
  echo "Flow Central Starting"
  time java -jar opcmd.jar start
  echo "Flow Central Started" 
  echo "Create initialized file"
  cd /opt/axway/FlowCentral
  touch ./runtime/initialized
  echo "Finished creating file"
else
  cd /opt/axway/FlowCentral/
  tail -F $(find /opt/axway/fc_logs -name "*.log") &
  cd /opt/axway/FlowCentral
  time java -jar opcmd.jar start
fi
