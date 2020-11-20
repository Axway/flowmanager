#! /bin/bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
else
  echo "Please provide .env file."
fi

if [ -z "$1" ]; then
    echo "No argument supplied. Please supply the path towards the license file and provide the necessary permissions."
    exit 0
fi


if [[ -f "$1" ]]; then
        cp $1 $pathToLicense/
else
        echo "The license file does not exist, please check the file permissions and run the script again with the correct path."
fi

./gen-amplify-certs.sh
./gen-certs.sh

