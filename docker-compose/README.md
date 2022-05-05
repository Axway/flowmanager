# docker-compose

This README refers to managing single-node installations of Flow Manager using `docker-compose`.

## Requirements

* [docker](https://docs.docker.com/engine/install/) version 18.x.x or higher
* [docker-compose](https://docs.docker.com/compose/install/) version 1.27.x or higher
* Flow Manager license and certificates files
* Mongodb 4.2 Docker Image (if not available in the local docker repository, will be donwloaded from Docker Hub).

## ***Setup & Run***

#### Create service account & Docker login

* Log in to the Amplify Platform.
* Select your organization, and from the left menu, click Service Accounts (You should see all service accounts already created).
* Click + Service Account, and fill in the mandatory fields:
* Enter a name for the service account.
* Choose Client Secret for the method.
* Choose Platform-generated secret for the credentials.
* Click Save
* Ensure to securely store the generated client secret because it will be required in further steps.
* Perform docker login using:
`docker login -u <SERVICE_ACCOUNT> -p <PASSWORD> docker.repository.axway.com`

#### Install Flow Manager

* Get the zip file from [here](https://github.com/Axway/docker-flowmanager/archive/master.zip) and unzip it
* Go to `docker-compose` path
* Add license file in `files/flowmanager/license`
* Run `./flowmanager_helper.sh setup` command. This will generate, add certificates in configs space and create a `.env` file (to add your certificates check __[Add your own certificates files](#add-your-own-certificates-files)__ section for more information)
* Change `.env` file values, following env.template, add other parameters based on your needs or leave them as default
* After you done, run `./flowmanager_helper.sh start`. This will start the containers with Flow Manager and database
* Check the health of the services by typing this `./flowmanager_helper.sh status` command.

### Add your own certificates files

* Add your own certificates in `files/flowmanager/configs` dir
* Replace the current certificates name with yours in `.env` file
* Run `./flowmanager_helper.sh start` command to start the containers with Flow Manager and database
* Check the health of the services by typing this `./flowmanager_helper.sh status` command.

***Note***: We support for the momment `jks`,`p12` and `pem` certificates extensions.

## ***Upgrade***

* Be sure you are in the same `docker-compose` path
* In `.env` file that you already have from `Run` section, change `FLOWMANAGER_VERSION` with the newer version
* Type `./flowmanager_helper.sh start` command, this will do the updating of your container with the new version
* Check the health of the services by typing this `./flowmanager_helper.sh status` command.

## ***Remove***

* Be sure you are in the same `docker-compose` path
* Type `./flowmanager_helper.sh delete`, this will remove all the containers, volumes and other parts related to the containers.

***WARNING***: Running `./flowmanager_helper.sh delete`  will remove all the volumes, including Mongodb data.

```text
./flowmanager_helper.sh is a helper script for run operations easily. If you are familiar with docker you can still use docker-compose commands.
```

### Extra configuration

#### Flow Manager parameters

The file `env.template` contains basic parameters that can be configured at Flow Manager start. The extended list can be consulted below. In order to add a new parameter, simply add it in your `.env` file and will be considered at Flow Manager.

All active Environment variables/parameters for Flow Manager, including all the services required to run can be found [here](../docs/README.md).

#### Enable transport encryption (TLS/SSL) for Mongodb

Encrypt all of Mongodb’s network traffic. TLS/SSL ensures that Mongodb network traffic is only readable by the intended client.

* Go to `docker-compose/files/mongo/config` path
* Uncomment `ssl` block from `mongod.conf` file
* Bring or generate certificate files in path you already are
* Change value of `CAFile` and `PEMKeyFile` parameters with yours (only name of certificate files)
* Save it
* Run `./flowmanager_helper.sh start` command in case you run Mongodb for the first time  or `./flowmanager_helper.sh restart mongodb` in case you already have Mongodb up.

## ***Upgrade Mongo 3.6 to 4.2***

* Run [upgradeMongo42.sh](../scripts/upgradeMongo42.sh).

## ***Migrate old Docker Compose model to .env file model***
### Prerequisites:
- Install [yq](https://github.com/mikefarah/yq) on your machine
- Clone the latest version of [docker-flowmanager](https://github.com/Axway/docker-flowmanager)
- Have the old Mongo database up and running in the container

### Usage
The migration script will perform the following actions:
- Generate a _.env_ file based on the old Docker Compose environment variables
- Export data from the old database using [mongodump](https://docs.mongodb.com/database-tools/mongodump/) and store it in the current directory in a binary file named _db.dump_.
- Start the new Mongo database in a Docker container and import data from _db.dump_ file using [mongorestore](https://docs.mongodb.com/database-tools/mongorestore/)
- Stop the Docker container
```
./flowmanager_helper.sh migrate
```
The user will be asked to insert the absolute or relative path to the directory where the old Docker Compose file is located.

### Start Flow Manager Docker container
To be able to start Flow Manager with the new setup you have to:
- Copy all the certificates from the old installation to the new location according to the documentation
- Edit the variables in the _.env_ file that suit your needs. The values that contain paths should be modified as seen in the _env.template_ file.
