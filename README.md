# AMPLIFY Flow Central Docker

AMPLIFY Flow Central Docker

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

## Clone the Flow Central repository from GitHub

```console
git clone https://github.com/Axway/docker-flowcentral.git
cd docker-flowcentral
```

#### Create volumes for persistent data

 - mkdir -p ./mounts/configs         # This folder will contain the private and public keys required to connect to API Central alongside with the Flow Central license (under the name **license.xml**) and the `.jks`/`.p12` certificates.
 - mkdir -p ./mounts/fc_logs         # All the application logs will be stored in here.
 - mkdir -p ./mounts/fc_plugins         # Plugins for ST,CFT
 - mkdir -p ./mounts/fc_resources       # Include Sentinel resources
  

*Note* In order to persist data from the MongoDB container we create volumes where the Mongo data will be stored. **TAKE HEED**, you may use any MongoDB image you desire as Axway does not offer support and/or maintenance for the MongoDB image bundled alongside Flow Central.

 - mkdir -p ./mounts/mongo_data              # MongoDB data
 - mkdir -p ./mounts/mongo_certificates      # MongoDB Certificates for SSL use
 - mkdir -p ./mounts/mongo_config            # MongoDB configuration files
 
*Note* In order for the Flow Central and MongoDB services to be able to operate you have to give the appropriate permissions to folder where the volumes will be mounted.

Example : chmod -R 777 ./mounts

*Note*  The Flow Central `docker-compose.yml` file defines a volume as a mechanism for persisting data both generated and used by the MongoDB service required by Flow Central.
The MongoDB data is placed in this volume so it can be reused when creating and starting a new Flow Central container.

## Importing docker image after download.

 *Note*  docker load < (File_Name.tgz)
 
Check that the image is succesfully imported with docker images command.


## Customizing the Flow Central service

The docker-compose file describes the Flow Central service along with the MongoDB service it requires. Furthermore it allows the management and configuration of the aforementioned services parameters.

Before you start, you must specify the Flow Central image you want to use. For that you must edit the **image** entry under the **flowcentral** service and specify the image name using the following naming convention "< repository > : < tag >".

Example:
 ```console
  image: axway/flowcentral:1.0.20190809
```
Make sure that the folders created at the previous step correspond with those specified in the docker-compose file.

## Conecting to Api Catalog

In order to connect to Api Catalog please register the keys generated with the script found in **./scripts** folder or custom ones into Api Catalog and get the Client ID which you must enter into docker-compose under the `FC_APIC_CLIENTID` environment variable.


#### Using a custom MongoDB

In order to use a custom MongoDB service you must first comment/remove the entries under the `fcmongo` service located in the docker-compose file.

Furthermore you must edit the `flowcentral` service located in the same file. You must fill out the MongoDB environment variables with the appropriate values specific to your custom solution. Finally you must comment/remove the entry `depends_on` from the `flowcentral`.

When using mongo with ssl the truststore must be generated and put in the apropriated path.

**Note** At this moment we support only jks truststores


#### Docker-compose parameters

The following tables illustrate a list of available parameters from the docker-compose file. With these parameters you can fine tune Flow Central's configuration in order for it to better fit your use case.

### Docker-compose parameters (these parameters come with a default value, but they can be customized for your use case)

#### Flow Central

 **Parameter**                     |  **Values**  |  **Description**
 --------------------------------- | :----------: | ---------------
ACCEPT_EULA                        |  \<string>   |  Parameter which indicates your acceptance of the End User License Agreement (i.e. EULA).
FC_GENERAL_FQDN                    |  \<string>   |  Host address of the Flow Central instance.
FC_GENERAL_HOSTNAME                |  \<string>   |  Host name of the Flow Central instance.
FC_GENERAL_UI_PORT                 |  \<string>   |  Flow Central's UI port.
FC_GENERAL_ENCRYPTION_KEY          |  \<string>   |  Flow Central's encryption key.
FC_GENERAL_LOGGING_LEVEL           |  \<string>   |  Flow Central's logging levels.
FC_GENERAL_LICENSE                 |  \<string>   |  Name of the Flow Central license file.
FC_GENERAL_CUSTOM_LOCATION_PATH    |  \<string>   |  The location of logs inside of the docker image.
FC_LOGS_CONSOLE                    |  \<string>   |  Logs in console or in files.
FC_HTTPS_USE_CUSTOM_CERT           |  \<string>   |  Flag which informs Flow Central that you are using custom certificates.
FC_HTTPS_KEYSTORE                  |  \<string>   |  Name of the HTTPS certificate.
FC_HTTPS_CERT_ALIAS                |  \<string>   |  Alias of the HTTPS certificate.
FC_HTTPS_KEYSTORE_PASSWORD         |  \<string>   |  HTTPS certificate password.
FC_CFT_SHARED_SECRET               |  \<string>   |  Flow Central's shared secret.
FC_APIC_USE_CATALOG                |  \<string>   |  Flag which indicates whether Flow Central should enable or disable the connection to ApiCatalog.
FC_APIC_HOST                       |  \<string>   |  ApiCatalog Host.
FC_APIC_CLIENTID                   |  \<string>   |  ApiCatalog's Client ID.
FC_APIC_PUBLICKEY                  |  \<string>   |  ApiCatalog's Public Key.
FC_APIC_PRIVATEKEY                 |  \<string>   |  ApiCatalog's Private Key.
FC_APIC_TOKENURL                   |  \<string>   |  ApiCatalog's Token Url.
FC_MONGODB_HOST                    |  \<string>   |  MongoDB host name.
FC_MONGODB_PORT                    |  \<number>   |  MongoDB port.
FC_MONGODB_USER_NAME               |  \<string>   |  Flow Central's user MongoDB user.
FC_MONGODB_USER_PASSWORD           |  \<string>   |  Flow Central's user MongoDB user's password.
FC_MONGODB_USE_SSL                 |  \<string>   |  MongoDB option for use of SSL. 
FC_MONGODB_TRUSTSTORE_FILE         |  \<string>   |  MongoDB truststore. (At the moment we support only jks.)
FC_DISABLE_CHECK_REACHABLE_HOST    |  \<string>   |  FlowCentral will not check if the mongodb instance is available.
FC_BUSINESS_CA_CERTIF_ALIAS        |  \<string>   |  Custom business certificate's internal alias.
FC_BUSINESS_CA_FILE                |  \<string>   |  File name and path to the custom business certificate.
FC_BUSINESS_CA_PASSWORD            |  \<string>   |  Custom business certificate's password.
FC_GOVERNANCE_CA_CERTIF_ALIAS      |  \<string>   |  Custom governance certificate internal alias.
FC_GOVERNANCE_CA_FILE              |  \<string>   |  File name and path to custom governance certificate.
FC_GOVERNANCE_CA_PASSWORD          |  \<string>   |  Custom governance certificate password.
FC_JVM_XMX                         |  \<string>   |  JVM maximum memory allocation pool.
FC_JVM_XMS                         |  \<string>   |  JVM maximum memory allocation pool.
FC_JVM_XMN                         |  \<string>   |  JVM size of the heap for the young generation.       
FC_JVM_DEBUG_ENABLED               |  \<string>   |  JVM Debug. 
FC_JVM_DEBUG_PORT                  |  \<string>   |  JVM Debug Port.         
FC_JVM_DEBUG_SUSPEND               |  \<string>   |  JVM Debug Suspend.  
FC_JVM_CUSTOM_ARGS                 |  \<string>   |  JVM Custom arguments.
FC_EXTERNAL_FQDN                   |  \<string>   |  FlowCentral external FQDN. (For when you are using the product from behind a loadbalancer)               
FC_EXTERNAL_UI_PORT                |  \<string>   |  FlowCentral external port.           
FC_SENTINEL_AUDIT_ENABLED          |  \<string>   |  Enable/Disable Sentinel audit.
FC_SENTINEL_FRONT_END_HOST         |  \<string>   |  Sentinel FQDN.  
FC_SENTINEL_FRONT_END_PORT         |  \<string>   |  Sentinel frontend port.   
FC_SENTINEL_FRONT_END_SSL_PORT     |  \<string>   |  Sentinel frontend ssl port. 
FC_SENTINEL_UI_PORT                |  \<string>   |  Sentinel ui port.    
FC_SENTINEL_USE_CG_CA              |  \<string>   |  Use FlowCentral CA for Sentinel.         


## Flow Central service operations

#### 1. Create and start the Flow Central service

From the folder where the `docker-compose.yml` file is located, run the command:

```console
docker-compose up
```

The `up` command pulls the Flow Central image from DockerHub, recreates, starts, and attaches to a container for services.
Unless they are already running, this command also starts any linked services.

You can use the `-d` option to run containers in the background.

```console
docker-compose up -d
```

Run the docker `ps` command to see the running containers.

```console
docker ps
```

#### 2. Stop and remove the Flow Central service

From the folder where the `docker-compose.yml` file is located, you can stop the containers using the command:

```console
docker-compose down
```

The `down` command stops containers, and removes containers, networks, anonymous volumes, and images created by `up`.
You can use the `-v` option to remove named volumes declared in the `volumes` section of the Compose file, and anonymous volumes attached to containers.

***BE CAREFULL*** When using the Flow Central Docker image in production, the following command `docker-compose down -v` will remove any persistent data associated with your Flow Central containers.
***It will essentially result in a clean slate for your Flow Central services.***

#### 3. Start the Flow Central service

From the folder where the `docker-compose.yml` file is located, you can start the Flow Central service using `start` if it was stopped using `stop`.

```console
docker-compose start
```

#### 4. Stop Flow Central service

From the folder where the `docker-compose.yml` file is located, you can stop the containers using the command:

```console
docker-compose stop
```

## Helper scripts

This sections details the usage of the helper scripts included alongside the Flow Central docker-compose. There are 2 helper scripts, namely: **gen-amplify-certs.sh** and **gen-certs.sh**.

Their usage will be detailed in the following sections.

*Note* In order for these scripts to function you will **require** **read, write and execute permissions** in the folder in which they are located as well as the following **packages**: **openssl**.

#### Using "gen-amplify-certs.sh"

This script generates the public and private keys required by the Flow Central service in order to connect to the amplify products stack. The files will be located in the same directory as the script being used to generate them. By default they need to be placed in the `./configs` directory.

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

