# docker-compose

This README refers to managing single-node installations of Flow Manager using `docker-compose`.

## Requirements

* [docker](https://docs.docker.com/engine/install/) version 18.x.x or higher
* [docker-compose](https://docs.docker.com/compose/install/) version 1.27.x or higher
* Flow Manager Docker Image downloaded from Axway Sphere
* Flow Manager license and certificates files
* Mongodb 4.2 Docker Image (if not available in the local docker repository, will be donwloaded from Docker Hub).

## ***Setup & Run***

* Get the zip file from [here](https://github.com/Axway/docker-flowmanager/archive/master.zip) and unzip it
* Go to `docker-compose` path
* Add license file in `files/flowmanager/license`
* Run `./flowmanager setup` command. This will generate, add certificates in configs space and create a `.env` file (to add your certificates check __[Add your own certificates files](#add-your-own-certificates-files)__ section for more information)
* Change `.env` file values, following env.template, add other parameters based on your needs or leave them as default
* After you done, run `./flowmanager start`. This will start the containers with Flow Manager and database
* Check the health of the services by typing this `./flowmanager status` command.

### Add your own certificates files

* Add your own certificates in `files/flowmanager/configs` dir
* Replace the current certificates name with yours in `.env` file
* Run `./flowmanager start` command to start the containers with Flow Manager and database
* Check the health of the services by typing this `./flowmanager status` command.

***Note***: We support for the momment `jks`,`p12` and `pem` certificates extensions.

## ***Upgrade***

* Be sure you are in the same `docker-compose` path
* In `.env` file that you already have from `Run` section, change `FLOWMANAGER_VERSION` with the newer version
* Type `./flowmanager start` command, this will do the updating of your container with the new version
* Check the health of the services by typing this `./flowmanager status` command.

## ***Remove***

* Be sure you are in the same `docker-compose` path
* Type `./flowmanager delete`, this will remove all the containers, volumes and other parts related to the containers.

***WARNING***: Running `./flowmanager delete`  will remove all the volumes, including Mongodb data.

```text
./flowmanager is a helper script for run operations easily. If you are familiar with docker you can still use docker-compose commands.
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
* Run `./flowmanager start` command in case you run Mongodb for the first time  or `./flowmanager restart mongodb` in case you already have Mongodb up.

## ***Upgrade Mongo 3.6 to 4.2***

* Connect to the running Mongo 3.6 container (docker exec -it <container_id> /bin/bash)
* Establish the connection with mongo using root inside the container (mongo -u root)
* Run the following command: `db.adminCommand( { setFeatureCompatibilityVersion: "4.0" } )`
* Change the mongo image with the version 4.2
