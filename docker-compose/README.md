# docker-compose

This README refers to managing single-node installations of Flow Manager using `docker-compose`.

## Requirements

* [docker](https://docs.docker.com/engine/install/) version 19.03.x or higher
* [docker-compose](https://docs.docker.com/compose/install/) version 1.27.x or higher
* Flow Manager Docker Image downloaded from Axway Sphere
* Flow Manager license and certificates files
* Mongodb 3.6 Docker Image (if not available in the local docker repository, will be donwloaded from Docker Hub).

## ***Setup & Run***

* Clone the repo by typing `git clone https://github.com/Axway/docker-flowmanager.git` command
* Go to `docker-compose` path
* Add license file in `files/flowmanager/license`
* Run `./flowmanager setup` command. This will generate, add certificates in configs space and create a `.env` file (to add your certificates check [here](#add-your-own-certificates-files) for more information)
* In `.env` file you can change values, add other parameters based on your needs or leave them as default
* After you done, run `./flowmanager start`. This will start the containers with Flow Manager and database
* Check the health of the services by typing this `./flowmanager status` command.

### Add your own certificates files

* Add your own certificates in `files/flowmanager/configs` dir
* Replace the current certificates name with yours in `.env` file
* Run `./flowmanager start` command to start the containers with Flow Manager and database
* Check the health of the services by typing this `./flowmanager status` command.

***Note***: We support for the momment `jks` and `pem` certificates extensions.

## ***Upgrade***

* Be sure you are in the same `docker-compose` path
* In `.env` file that you already have from `Run` section, change `FLOWMANAGER_VERSION` with the newer version
* Type `./flowmanager start` command, this will do the updating of your container with the new version
* Check the health of the services by typing this `./flowmanager status` command.

## ***Remove***

* Be sure you are in the same `docker-compose` path
* Type `./flowmanager delete`, this will remove all the containers, volumes and other parts related to the containers.

***WARNING***: Running `./flowmanager delete`  will remove all the volumes, including Mongodb data.

### Extra configuration

<details>
  <summary>Flow Manager parameters</summary>

The file `env.template` contains basic fields that can be configured at Flow Manager start. The extended list can be consulted below. In order to add a new parameter, simply add it in your `.env` file and will be considered at Flow Manager.

All active Environment variables/parameters for Flow Manager, including all the services required to run can be found [here](../docs/parameters.md).
</details>

<details>
  <summary>Enable transport encryption (TLS/SSL) for Mongodb</summary>

Encrypt all of Mongodb’s network traffic. TLS/SSL ensures that Mongodb network traffic is only readable by the intended client.

* Go to `docker-compose/files/mongo/config` path
* Uncomment `ssl` block from `mongod.conf` file
* Bring or generate certificate files in path you already are
* Change value of `CAFile` and `PEMKeyFile` parameters with yours (only name of certificate files)
* Save it
* Run `./flowmanager start` command in case you run Mongodb for the first time  or `./flowmanager restart mongodb` in case you already have Mongodb up.

</details>

<details>
  <summary>Migrate data from one container to another</summary>

  Steps to move your current data from an existing container (that uses a custom docker image) to new container (that uses an official docker image) can be found [here](../docs/migrate_data_mongodb.md).

</details>
