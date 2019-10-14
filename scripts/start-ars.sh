#!/bin/sh
set -euo pipefail
ACCEPT_EULA="${ACCEPT_EULA:-no}"

if [[ $ACCEPT_EULA = "yes" ]]; then
    echo "You have accepted the EULA, the configuration will proceed as normal."
else
    echo "You have not accepted the EULA, please accept it otherwise the configuration will not proceed. Exiting now."
    exit 1
fi

#redirect logs to stdout

FC_LOGS_CONSOLE="${FC_LOGS_CONSOLE:-no}"

if [[ $FC_LOGS_CONSOLE = "yes" ]]; then
    mkdir -p $FC_GENERAL_CUSTOM_LOCATION_PATH/logs/
    ln -sf /dev/stdout $FC_GENERAL_CUSTOM_LOCATION_PATH/logs/kernel.log
    ln -sf /dev/stdout $FC_GENERAL_CUSTOM_LOCATION_PATH/logs/opnode.log
    ln -sf /dev/stdout $FC_GENERAL_CUSTOM_LOCATION_PATH/logs/performance.log
else
    echo "Logs are sent to files"
fi

ln -sf /dev/stdout /opt/axway/FlowCentral/logs/commonsso.log
ln -sf /dev/stdout /opt/axway/FlowCentral/logs/errout.txt
ln -sf /dev/stdout /opt/axway/FlowCentral/logs/opcmd.log.0
ln -sf /dev/stdout /opt/axway/FlowCentral/logs/opcmd.log.0.1
ln -sf /dev/stdout /opt/axway/FlowCentral/logs/stdout.txt

cp /opt/axway/configs/license.xml /opt/axway/FlowCentral/conf/license/license.xml

  cd /opt/axway/FlowCentral
  echo "Configuring Product Started"
  time java -jar opcmd.jar configure -n -s /opt/axway/FlowCentral/conf.properties -env
  echo "Configuring Product Ended"


if [ ! -f /opt/axway/FlowCentral/runtime/initialized ]; then 
  touch ./runtime/initialized
  echo "Flow Central Starting"
  time java -jar opcmd.jar start 
  echo "Flow Central Started"
else
  echo "Flow Central Starting"
  cd /opt/axway/FlowCentral
  time java -jar opcmd.jar start
  echo "Flow Central Started"
fi

while true ; do
  sleep 600
done