#!/bin/sh
set -euo pipefail
ACCEPT_EULA="${ACCEPT_EULA:-no}"

if [[ $ACCEPT_EULA = "yes" ]]; then
	echo "You have accepted the EULA, the configuration will proceed as normal."
else
	echo "You have not accepted the EULA, please accept it otherwise the configuration will not proceed. Exiting now."
	exit 1
fi

set_status() {
  cd /opt/axway/FlowCentral/
  echo "$1" > "/opt/axway/FlowCentral/"$(dirname $(find runtime -name "index.html" | grep "ROOT/login/index.html"))/status.html
}

  cd /opt/axway/FlowCentral
  echo "Configuring Product Started"
  time java -jar opcmd.jar configure -n -s /opt/axway/FlowCentral/conf.properties -env
  echo "Configuring Product Ended"

function monitor_log() {
  echo > /opt/axway/monitored
  local new=""
  while true; do
    new=""
    (find $FC_GENERAL_CUSTOM_LOCATION_PATH -name "*.log" -o -name "*.log.0" || echo "") | while read file; do
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
  set_status "STARTING"
  touch ./runtime/initialized
  echo "Flow Central Starting"
  time java -jar opcmd.jar start 
  echo "Flow Central Started"
  set_status "READY"
else
  set_status "STARTING"
  tail -F $(find /opt/axway/fc_logs -name "*.log") &
  cd /opt/axway/FlowCentral
  time java -jar opcmd.jar start
  set_status "READY"
fi

while true status; do
  sleep 600
done