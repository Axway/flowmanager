# Parameters

All active Environment variables/parameters for Flow Manager, including all the services required to run.

## Application

|**Parameter**|**Require**|**Type**|**Description**|**Default**|
|-------------|:---------:|:------:|---------------|-----------|
|FLOWMANAGER_IMAGE_URL*|No|`string`|URL from where you want to get the image|`axway/flowmanager`|
|FLOWMANAGER_VERSION*|Yes|`number`|App version based on docker image||
|ACCEPT_EULA|Yes|`string`|Indicates your acceptance of the End User License Agreement|`yes`|
|FM_GENERAL_FQDN|Yes|`string`|URL address of the FlowManager instance||
|FM_GENERAL_UI_PORT|Yes|`number`|FlowManager UI port|`8081`|
|FM_GENERAL_ENCRYPTION_KEY|Yes|`number`|FlowManager's encryption key||
|FM_GENERAL_LOGGING_LEVEL|No|`string`|FlowManager's logging levels|`INFO`|
|FM_GENERAL_LICENSE|No|`string`|Name of the FlowManager license file|`license.xml`|
|FM_GENERAL_CUSTOM_LOCATION_PATH|No|`string`|The location of logs inside of the docker image||
|FM_LOGS_CONSOLE|No|`string`|Enable logs in the console|`yes`|
|FM_HTTPS_USE_CUSTOM_CERT|No|`string`|Flag which informs FlowManager that you are using custom certificates|`true`|
|FM_HTTPS_KEYSTORE|Yes|`string`|Name of the HTTPS certificate||
|FM_HTTPS_CERT_ALIAS|No|`string`|Alias of the HTTPS certificate|`ui`|
|FM_HTTPS_KEYSTORE_PASSWORD|Yes|`string`|HTTPS certificate password||
|FM_CFT_SHARED_SECRET|Yes|`string`|FlowManager's shared secret||
|FM_CFT_UPDATES_PATH|Yes|`string`|The path needed to update CFT plugin||
|FM_HTTPS_DISABLED|No|`string`|Set on `true` if the ssl requests are handled by a gateway (SSL termination)|`false`|
|FM_DATABASE_HOST|No|`string`|MongoDB host name|`mongodb`|
|FM_DATABASE_PORT|No|`number`|MongoDB port|`27017`|
|FM_DATABASE_USER_NAME|Yes|`string`|MongoDB user used for FlowManager||
|FM_DATABASE_USER_PASSWORD|Yes|`string`|MongoDB user's password used for FlowManager||
|FM_DATABASE_USE_SSL|No|`string`| MongoDB option for use of SSL|`false`|
|FM_DATABASE_CERTIFICATES|No|`string`|MongoDB truststore (At the moment we support only jks)||
|FM_DATABASE_AUTHSOURCE|No|`string`|The database in which the MongoDB user (`FM_DATABASE_USER_NAME`) was created. If not set, it means that the user belongs to the FlowManager database (`FM_DATABASE_NAME`).||
|FM_DATABASE_AUTH_MECHANISM|No|`string`|The client authentication mechanism. Possible values: `LDAP`, `SCRAM_SHA1`, `SCRAM_SHA256`. If not set, the default mongo client authentication mechanism will be used (`SCRAM_SHA1`). If LDAP is used, the `FM_DATABASE_AUTHSOURCE` should not be set because in this case its default value is `$external`.||
|FM_GOVERNANCE_CA_CERTIF_ALIAS|No|`string`|Custom governance certificate internal alias||
|FM_GOVERNANCE_CA_FILE|No|`string`|File name and path to custom governance certificate||
|FM_GOVERNANCE_CA_PASSWORD|No|`string`| Custom governance certificate password||
|FM_METRICS_ENABLED|No|`string`|Enable metrics for Prometheus|`false`|
|FM_JVM_XMX|No|`string`|JVM maximum memory allocation pool|`2G`|
|FM_JVM_XMS|No|`string`|JVM maximum memory allocation pool|`512M`|
|FM_JVM_XMN|No|`string`|JVM size of the heap for the young generation|`768M`|

## MongoDB

|**Parameter**|**Require**|**Type**|**Description**|**Default**|
|-------------|:---------:|:------:|---------------|-----------|
|MONGO_IMAGE_URL*|No|`string`|URL from where you want to get the image|`mongo`|
|MONGO_IMAGE_VERSION*|No|`number`|DB version based on docker image|`3.6`|
|MONGO_INTERNAL_PORT|No|`number`|DB port number|`27017`|
|MONGO_EXTERNAL_PORT|No|`number`|DB external container port|`27017`|
|MONGO_INITDB_ROOT_USERNAME|Yes|`string`|DB Super user||
|MONGO_INITDB_ROOT_PASSWORD|Yes|`string`|DB Super password||
|MONGO_APP_DATABASE|Yes|`string`|Database name for the application||
|MONGO_APP_USER|Yes|`string`|Database user for the application||
|MONGO_APP_PASS|Yes|`string`|Database password for the application||
|MONGO_BIND_IP|No|`string`|Bind to all IPv4 and IPv6 addresses|`0.0.0.0`|
|MONGO_CA_FILE|No|`string`|Contains the root certificate chain from the Certificate Authority||
|MONGO_PEM_KEY_FILE|No|`string`|Contains both the TLS/SSL certificate and key||

***
*Parameters for docker compose only.
