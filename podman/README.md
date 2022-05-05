# podman

This README refers to managing single-node installations of Flow Manager using `podman`.

## Requirements

* [podman](https://podman.io/getting-started/installation) version 3.0.1
* Flow Manager license and certificates files
* Mongodb 4.2 Docker Image (if not available in the local docker repository, will be donwloaded from Docker Hub).

## ***Setup & Run***

#### Create service account & Podman login

* Log in to the Amplify Platform.
* Select your organization, and from the left menu, click Service Accounts (You should see all service accounts already created).
* Click + Service Account, and fill in the mandatory fields:
* Enter a name for the service account.
* Choose Client Secret for the method.
* Choose Platform-generated secret for the credentials.
* Click Save
* Ensure to securely store the generated client secret because it will be required in further steps.
* Perform podman login using:
`podman login -u <SERVICE_ACCOUNT> -p <PASSWORD> docker.repository.axway.com`

#### Install Flow Manager

* Get the zip file from [here](https://github.com/Axway/docker-flowmanager/archive/master.zip) and unzip it
* Go to `podman` path
* Add license file in `files/flowmanager/license`
* Run `./flowmanager_helper.sh setup` command. This will generate, add certificates in configs space (to add your certificates check __[Add your own certificates files](#add-your-own-certificates-files)__ section for more information)
* Change deployment.yml file with your paramters
* After you done, run `./flowmanager_helper.sh start`. This will start the containers with Flow Manager and database

### Add your own certificates files

* Add your own certificates in `files/flowmanager/configs` dir
* Replace the current certificates name with yours in deployment.yml file
* Run `./flowmanager_helper.sh start` command to start the containers with Flow Manager and database

***Note***: We support for the momment `jks`,`p12` and `pem` certificates extensions.

## ***Remove***

* Be sure you are in the same `podman` path
* Type `./flowmanager_helper.sh delete`, this will remove all the containers, volumes and other parts related to the containers.

***WARNING***: Running `./flowmanager_helper.sh delete`  will remove all the volumes, including Mongodb data.

```text
./flowmanager_helper.sh is a helper script for run operations easily. If you are familiar with podman you can still use podman commands.
```

### Extra configuration

#### Flow Manager parameters

The file deployment.yml contains basic parameters that can be configured at Flow Manager start. The extended list can be consulted below. In order to add a new parameter, add it in your deployment.yml file and will be considered at Flow Manager.

All active Environment variables/parameters for Flow Manager, including all the services required to run can be found [here](../docs/README.md).

#### Enable transport encryption (TLS/SSL) for Mongodb

Encrypt all of Mongodb’s network traffic. TLS/SSL ensures that Mongodb network traffic is only readable by the intended client.

* Go to `podman/files/mongo/config` path
* Uncomment `ssl` block from `mongod.conf` file
* Bring or generate certificate files in path you already are
* Change value of `CAFile` and `PEMKeyFile` parameters with yours (only name of certificate files)
* Save it
* Run `./flowmanager_helper.sh start` command in case you run Mongodb for the first time  or `./flowmanager_helper.sh restart` in case you already have Mongodb up.
