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
CFTCONNECTOR_REGISTRATION_PORT="${CFTCONNECTOR_REGISTRATION_PORT:-12553}"
CFTCONNECTOR_SECURED_COMM_PORT="${CFTCONNECTOR_SECURED_COMM_PORT:-12554}"
GENERAL_LOGGING_LEVEL="${GENERAL_LOGGING_LEVEL:-INFO}"
GENERAL_REGISTRATION_APPROVAL="${GENERAL_REGISTRATION_APPROVAL:-false}"
GENERAL_SMTP_HOST="${GENERAL_SMTP_HOST:-localhost}"
GENERAL_SMTP_PORT="${GENERAL_SMTP_PORT:-25}"
PASSPORT_LEVEL_LOG="${PASSPORT_LEVEL_LOG:-INFO}"
UMA_PORT="${UMA_PORT:-5701}"
UME_USE_APP_FOR_PARTNER_ID="${UME_USE_APP_FOR_PARTNER_ID:-true}"
DEFAULT_USER_PASS="${DEFAULT_USER_PASS:-Initial02}"
NEW_USER_ID="${NEW_USER_ID:-isabelle}"
NEW_USER_PASS="${NEW_USER_PASS:-Initial02}"
UME_APIC_HOST="${UME_APIC_HOST}"
UME_APIC_CLIENTID="${UME_APIC_CLIENTID}"
CERTIFICATE_EXPIRATION_NOTIFICATION="${CERTIFICATE_EXPIRATION_NOTIFICATION:-60}"

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
 
  subst GENERAL_FQDN ${FQDN}
  subst GENERAL_HOSTNAME ${HOSTNAME}
  subst CG_SHARED_SECRET ${CG_SHARED_SECRET}
  subst CG_CONFIRM_SHARED_SECRET ${CG_SHARED_SECRET}
  subst ENCRYPTION_KEY ${ENCRYPTION_KEY}

  subst MONGODB_HOST ${MONGODB_HOST}
  subst MONGODB_PORT ${MONGODB_PORT}
  subst MONGODB_ROOT_NAME ${MONGODB_ROOT_NAME}
  subst MONGODB_USER_NAME ${MONGODB_USER_NAME}
  subst MONGODB_USER_PASSWORD ${MONGODB_USER_PASSWORD}
  subst MONGODB_ROOT_PASSWORD ${MONGODB_USER_PASSWORD}
  subst MONGODB_CONFIRM_ROOT_PASSWORD ${MONGODB_USER_PASSWORD}
  subst MONGODB_CONFIRM_USER_PASSWORD ${MONGODB_USER_PASSWORD}

  subst CFTCONNECTOR_REGISTRATION_PORT ${CFTCONNECTOR_REGISTRATION_PORT}
  subst CFTCONNECTOR_SECURED_COMM_PORT ${CFTCONNECTOR_SECURED_COMM_PORT}

  subst GENERAL_UI_PORT ${GENERAL_UI_PORT}
  subst GENERAL_LOGGING_LEVEL ${GENERAL_LOGGING_LEVEL}
  subst GENERAL_REGISTRATION_APPROVAL ${GENERAL_REGISTRATION_APPROVAL}
  subst GENERAL_SMTP_HOST ${GENERAL_SMTP_HOST}
  subst GENERAL_SMTP_PORT ${GENERAL_SMTP_PORT}

  subst UMA_PORT ${UMA_PORT}
  subst UME_USE_APP_FOR_PARTNER_ID ${UME_USE_APP_FOR_PARTNER_ID}
  subst UME_APIC_USE_CATALOG ${UME_APIC_USE_CATALOG}
  subst UME_APIC_TOKENURL ${UME_APIC_TOKENURL}
  subst BUSINESS_USE_CUSTOM_JKS ${BUSINESS_USE_CUSTOM}
  subst BUSINESS_CA_CERTIF_ALIAS ${BUSINESS_CA_CERTIF_ALIAS}
  subst BUSINESS_CA_FILE_CHOSEN ${BUSINESS_CA_FILE}
  subst BUSINESS_CA_PASSWORD ${BUSINESS_CA_PASSWORD}
  subst BUSINESS_CA_JKS ${BUSINESS_CA_FILE}

  subst GOVERNANCE_CA_CERTIF_ALIAS ${GOVERNANCE_CA_CERTIF_ALIAS}
  subst GOVERNANCE_CA_FILE_CHOSEN ${GOVERNANCE_CA_FILE}
  subst GOVERNANCE_CA_PASSWORD ${GOVERNANCE_CA_PASSWORD}
  subst GOVERNANCE_CA_JKS ${GOVERNANCE_CA_FILE}

  subst SECURITY_CG_UI_ALIAS ${SECURITY_CG_UI_ALIAS}
  subst SECURITY_CG_UI_PASSWORD ${SECURITY_CG_UI_PASSWORD}
  subst SECURITY_CG_UI_JKS ${SECURITY_CG_UI}

  subst UME_APIC_HOST ${UME_APIC_HOST}
  subst UME_APIC_CLIENTID ${UME_APIC_CLIENTID}

  subst UME_APIC_PUBLICKEY ${UME_APIC_PUBLICKEY}
  subst UME_APIC_PRIVATEKEY ${UME_APIC_PRIVATEKEY}
  
  cd /opt/axway/FlowCentral
  echo "Configuring Product Starting"
  time java -jar opcmd.jar configure -s /opt/axway/FlowCentral/conf.properties -consolelog -debug
  echo "Configuring Product Ended"
  cd /opt/axway/FlowCentral
  touch $PWD/runtime/initialized
else
  cd /opt/axway/FlowCentral/
  tail -F $(find /opt/axway/fc_logs -name "*.log") &
  cd /opt/axway/FlowCentral
  time java -jar opcmd.jar start
fi
