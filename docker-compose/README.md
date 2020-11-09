# docker-compose

This readme refers to managing single-node installations of Flow Manager using docker-compose.

## Requirements

* [docker](https://docs.docker.com/engine/install/) version 19.03.12 or higher
* [docker-compose](https://docs.docker.com/compose/install/) version 1.26.2 or higher
* Flow Manager Docker Image downloaded from Axway Sphere
* Flow Manager license and certificates files
* MongoDB 3.6 Docker Image (if not available in the local docker repository, will be donwloaded from Docker Hub).

## ***Install***

* Clone the repo by typing `git clone https://github.com/Axway/docker-flowmanager.git` command
* Go to `docker-compose` path
* Copy `env.template` in `.env` file
* Change value of parameters as you want in `.env` file
* Run docker `docker-compose up -d`
* Check the health of the services by typing this `docker-compose ps` command.

## ***Upgrade***

* Be sure you are in the same `docker-compose` path
* In `.env` file that you already have from install stage, change `FLOWMANAGER_VERSION` with the newer version
* Type `docker-compose up -d` command, this will do the updating of your container with the new version
* Check the health of the services by typing this `docker-compose ps` command.

## ***Remove***

* Be sure you are in the same `docker-compose` path
* Type `docker-compose down -v`, this will remove all the containers, volumes and other parts related to the containers.

***WARNING!*** Running `docker-compose down -v`  will remove all the volumes, including MongoDB data!

### Extra configuration

<details>
  <summary>Flow Manager parameters</summary>

The file `env.template` contains basic fields that can be configured at Flow Manager start. The extended list can be consulted below. In order to add a new parameter, simply add it in your `.env` file and will be considered at Flow Manager.

All active Environment variables/parameters for Flow Manager, including all the services required to run can be found [here](../docs/parameters.md).
</details>

<details>
  <summary>Enable transport encryption (TLS/SSL) for MongoDB</summary>

Encrypt all of MongoDB’s network traffic. TLS/SSL ensures that MongoDB network traffic is only readable by the intended client.

* Go to `docker-compose/files/mongo/config` path
* Uncomment `ssl` block from `mongod.conf` file
* Bring or generate certificate files in path you already are
* Change value of `CAFile` and `PEMKeyFile` parameters with yours (only name of certificate files)
* Save it
* Run `docker-compose up -d` command in case you run MongoDB for the first time  or `docker-compose restart mongodb` in case you already have MongoDB up.

</details>

<details>
  <summary>Migrate data from one container to another</summary>

  Steps to move your current data from an existing container (that uses a custom docker image) to new container (that uses an official docker image) can be found [here](../docs/migrate_data_mongodb.md).

</details>
