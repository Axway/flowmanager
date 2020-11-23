# Generate pem and p12 certs

There are three scripts:
1. **quickstart.sh** : It generates all needed certificates and the license is moved in the right location. (the script calls gen-certs.sh and gen-amplify-certs.sh)
2. **gen-certs.sh**  : It generates ui, governance and business certificates in p12 and pem formats.
3. **gen-amplify-certs.sh** : It generates catalog certificates in pem format.


All the configurable parameters are stored in a hidden file called ".env" .

In order to see this file, run:
`ls -a`

In order to change the variables, run:
`vi .env`

The following parameters can be modified:

| Parameter | Default |
| ------ | ------ |
| pathToCerts | ../docker-compose/files/flowmanager/config |
| pathToLicense | ../docker-compose/files/flowmanager/license |
| site | example.com |
| email | anonymous@axway.com |
| password | Secret01 |
| default_days | 10 |

- The scripts should be run from their location. (./scripts/). If the scripts are run from a different location, please, update the paths accordingly. 
