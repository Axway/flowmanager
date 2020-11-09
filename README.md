# AMPLIFY Flow Manager Docker

AMPLIFY Flow Manager Docker.

---

**New deployment version is here**

Soon we will update the main branch with the new version. New version can be found in [improve/deployment](https://github.com/Axway/docker-flowmanager/tree/improve/deployment) branch.

---

## Content

- Docker-Compose: Orchestration infrastructure.

## Before you begin

This document assumes a basic understanding of core Docker concepts such as containers, container images, and basic Docker commands.
If needed, see [Get started with Docker](https://docs.docker.com/get-started/) for a primer on container basics.

## Prerequisites

- Git
- Docker version 17.09 or higher
- Docker-Compose version 1.17.0 or higher
- Download docker image from product site.
- Create the directories where you wish to bind your volumes
- License and certificates
- MongoDB instance


#### Installing the necessary prerequisites  (Git, Docker Engine and Docker Compose)

##### Installing Git

*Note* Debian/Ubuntu
```console
sudo apt install -y git
```

*Note* Centos/RHEL
```console
sudo yum install -y git
```

 ***(More details on Git installation can be found at the following url: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git )***

##### Installing the Docker Engine and Docker Compose

*Note* Details on installing Docker Engine for Linux based systems can be found here: https://docs.docker.com/cs-engine/1.12/.

*Note* Details on installing Docker Compose can be found here : https://docs.docker.com/compose/install/.

 ***(More details on Docker and Docker Compose can be found here: https://docs.docker.com/ )***

##### In order to obtain the necessary license files please contact your local Axway vendor

## Clone the Flow Manager repository from GitHub

```console
git clone https://github.com/Axway/docker-flowmanager.git
cd docker-flowmanager
```

#### Create volumes for persistent data

 - mkdir -p ./mounts/configs         # This folder will contain the private and public keys required to connect to API Manager alongside with the Flow Manager license (under the name **license.xml**) and the `.jks`/`.p12` certificates.
 - mkdir -p ./mounts/logs            # All the application logs will be stored in here.
 - mkdir -p ./mounts/plugins         # Plugins for ST,CFT
 - mkdir -p ./mounts/resources       # Include Sentinel resources


*Note* In order to persist data from the MongoDB container we create volumes where the Mongo data will be stored. **TAKE HEED**, you may use any MongoDB image you desire as Axway does not offer support and/or maintenance for the MongoDB image bundled alongside Flow Manager.

 - mkdir -p ./mounts/mongo_certificates      # MongoDB Certificates for SSL use
 - mkdir -p ./mounts/mongo_config            # MongoDB configuration files

*Note* In order for the Flow Manager and MongoDB services to be able to operate you have to give the appropriate permissions to folder where the volumes will be mounted.

Example : chmod -R 777 ./mounts

*Note*  The Flow Manager `docker-compose.yml` file defines a volume as a mechanism for persisting data both generated and used by the MongoDB service required by Flow Manager.
The MongoDB data is placed in this volume so it can be reused when creating and starting a new Flow Manager container.

## Importing docker image after download.

Example : docker load < (File_Name.tgz)

Check that the image is succesfully imported with docker images command.


## Customizing the Flow Manager service

The docker-compose file describes the Flow Manager service along with the MongoDB service it requires. Furthermore it allows the management and configuration of the aforementioned services parameters.

Before you start, you must specify the Flow Manager image you want to use. For that you must edit the **image** entry under the **flowmanager** service and specify the image name using the following naming convention "< repository > : < tag >".

Example:
 ```console
  image: axway/flowmanager:2.0.20190809
```
Make sure that the folders created at the previous step correspond with those specified in the docker-compose file.

## Updating Flow Manager

1. Download the new image
2. Import it localy
3. docker-compose down (this will stop the containers)
4. Edit docker compose with new image name
5. docker-compose up (this will start the containers and the update will be done)


#### Using a custom MongoDB

In order to use a custom MongoDB service you must first comment/remove the entries under the `fmmongo` service located in the docker-compose file.

Furthermore you must edit the `flowmanager` service located in the same file. You must fill out the MongoDB environment variables with the appropriate values specific to your custom solution. Finally you must comment/remove the entry `depends_on` from the `flowmanager`.

When using mongo with ssl the truststore must be generated and put in the apropriated path.

**Note** At this moment we support only jks truststores


#### Docker-compose parameters

The following tables illustrate a list of available parameters from the docker-compose file. With these parameters you can fine tune Flow Manager's configuration in order for it to better fit your use case.

### Docker-compose parameters (these parameters come with a default value, but they can be customized for your use case)

#### Flow Manager

 **Parameter**                     |  **Values**  |  **Description**
 --------------------------------- | :----------: | ---------------
ACCEPT_EULA                        |  \<string>   |  Parameter which indicates your acceptance of the End User License Agreement (i.e. EULA).
FM_GENERAL_FQDN                    |  \<string>   |  Host address of the Flow Manager instance.
FM_GENERAL_UI_PORT                 |  \<string>   |  Flow Manager's UI port.
FM_GENERAL_ENCRYPTION_KEY          |  \<string>   |  Flow Manager's encryption key.
FM_GENERAL_LOGGING_LEVEL           |  \<string>   |  Flow Manager's logging levels.
FM_GENERAL_CUSTOM_LOCATION_PATH    |  \<string>   |  The location of logs inside of the docker image.
FM_LOGS_CONSOLE                    |  \<string>   |  Logs in console or in files.
FM_HTTPS_USE_CUSTOM_CERT           |  \<string>   |  Flag which informs Flow Manager that you are using custom certificates.
FM_HTTPS_KEYSTORE                  |  \<string>   |  Name of the HTTPS certificate.
FM_HTTPS_CERT_ALIAS                |  \<string>   |  Alias of the HTTPS certificate.
FM_HTTPS_KEYSTORE_PASSWORD         |  \<string>   |  HTTPS certificate password.
FM_CFT_SHARED_SECRET               |  \<string>   |  Flow Manager's shared secret.
FM_DATABASE_HOST                   |  \<string>   |  MongoDB host name.
FM_DATABASE_PORT                   |  \<number>   |  MongoDB port.
FM_DATABASE_USER_NAME              |  \<string>   |  Flow Manager's user MongoDB user.
FM_DATABASE_USER_PASSWORD          |  \<string>   |  Flow Manager's user MongoDB user's password.
FM_DATABASE_USE_SSL                |  \<string>   |  MongoDB option for use of SSL.
FM_DATABASE_CERTIFICATES           |  \<string>   |  MongoDB truststore. (At the moment we support only jks.)
FM_GOVERNANCE_CA_CERTIF_ALIAS      |  \<string>   |  Custom governance certificate internal alias.
FM_GOVERNANCE_CA_FILE              |  \<string>   |  File name and path to custom governance certificate.
FM_GOVERNANCE_CA_PASSWORD          |  \<string>   |  Custom governance certificate password.
FM_JVM_XMX                         |  \<string>   |  JVM maximum memory allocation pool.
FM_JVM_XMS                         |  \<string>   |  JVM maximum memory allocation pool.
FM_JVM_XMN                         |  \<string>   |  JVM size of the heap for the young generation.
FM_JVM_DEBUG_ENABLED               |  \<string>   |  JVM Debug.
FM_JVM_DEBUG_PORT                  |  \<string>   |  JVM Debug Port.
FM_JVM_DEBUG_SUSPEND               |  \<string>   |  JVM Debug Suspend.
FM_JVM_CUSTOM_ARGS                 |  \<string>   |  JVM Custom arguments.

## Flow Manager service operations

#### 1. Create and start the Flow Manager service

From the folder where the `docker-compose.yml` file is located, run the command:

```console
docker-compose up
```

The `up` command pulls the Flow Manager image from DockerHub, recreates, starts, and attaches to a container for services.
Unless they are already running, this command also starts any linked services.

You can use the `-d` option to run containers in the background.

```console
docker-compose up -d
```

Run the docker `ps` command to see the running containers.

```console
docker ps
```

#### 2. Stop and remove the Flow Manager service

From the folder where the `docker-compose.yml` file is located, you can stop the containers using the command:

```console
docker-compose down
```

The `down` command stops containers, and removes containers, networks, anonymous volumes, and images created by `up`.
You can use the `-v` option to remove named volumes declared in the `volumes` section of the Compose file, and anonymous volumes attached to containers.

***BE CAREFUL*** When using the Flow Manager Docker image in production, the following command `docker-compose down -v` will remove any persistent data associated with your Flow Manager containers.
***It will essentially result in a clean slate for your Flow Manager services.***

#### 3. Start the Flow Manager service

From the folder where the `docker-compose.yml` file is located, you can start the Flow Manager service using `start` if it was stopped using `stop`.

```console
docker-compose start
```

#### 4. Stop Flow Manager service

From the folder where the `docker-compose.yml` file is located, you can stop the containers using the command:

```console
docker-compose stop
```

## Helper scripts

This sections details the usage of the helper scripts included alongside the Flow Manager docker-compose. There are 2 helper scripts, namely: **gen-amplify-certs.sh** and **gen-certs.sh**.

Their usage will be detailed in the following sections.

*Note* In order for these scripts to function you will **require** **read, write and execute permissions** in the folder in which they are located as well as the following **packages**: **openssl**.

#### Using "gen-amplify-certs.sh"

This script generates the public and private keys required by the Flow Manager service in order to connect to the amplify products stack. The files will be located in the same directory as the script being used to generate them. By default they need to be placed in the `./configs` directory.

*Note* The following example details the use of the aforementioned script.

Example:
```console
./scripts/gen-amplify-certs.sh
```

#### Using "gen-certs.sh"

This script takes care of generating the `.p12` default certificates. It also has the embedded functionality to generate the `.jks` certificates as well although it is not enabled by default. Inside it are included all the necessary parameters in order to generate the basic certificates but you are free to edit them as per your custom use scenario.

Besides generating the certificates it will also copy them into the default volume mounts specified in the docker-compose.

Example:
```console
./scripts/gen-certs.sh
```

#### Using "quickstart.sh"

This script will create all the directories mentioned above and will execute the 2 scripts that generate certificates/keys.

Example:
```console
./scripts/quickstart.sh
```


## Security notices

`*Note*` You may use an existing MongoDB instance or our bundled up MongoDB service which will be deployed by default when running with our docker-compose.

 `*Note*` The image axway/mongodb is using the official mongo:3.6 image on top of it we added some scripts specific to the application. **We are not managing the mongo:3.6 image**.

