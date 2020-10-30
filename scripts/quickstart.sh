#! /bin/bash

if [ ! -f ./docker-compose.yml ]; then
    cd ../docker-compose
     if [ ! -f ./docker-compose.yml ]; then
          echo "You should launch this script from docker-compose directory!"
          exit 1
     fi
fi

if [ -z "$1" ]; then
    echo "No argument supplied. Please supply the path towards the license file and provide the necessary permissions."
    exit 0
fi


if [[ -f "$1" ]]; then
        cp $1 ./files/license/
else
        echo "The license file does not exist, please check the file permissions and run the script again with the correct path."
fi

./../scripts/gen-amplify-certs.sh
./../scripts/gen-certs.sh

