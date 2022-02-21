# Parameters

All active Environment variables/parameters for Flow Manager, including all the services required to run.

## Flow Manager

|**Parameter**|**Mandatory**|**Description**|**Default value**|
|-------------|------------|---------------|-----------------|
|FLOWMANAGER_IMAGE_URL*|No|URL from where you want to get the image|`axway/flowmanager`|
|FLOWMANAGER_VERSION*|Yes|App version based on docker image||
|ACCEPT_EULA|Yes|Indicates your acceptance of the End User License Agreement|`false`|
|FM_GENERAL_FQDN|Yes|URL address of the FlowManager instance||
|FM_GENERAL_UI_PORT|Yes|FlowManager UI port|`8081`|
|FM_GENERAL_ENCRYPTION_KEY|Yes|FlowManager's encryption key||
|FM_GENERAL_LOGGING_LEVEL|No|FlowManager's logging levels|`INFO`|
|FM_LOGS_CONSOLE|No|Enable logs in the console|`true`|
|FM_GENERAL_CUSTOM_LOCATION_PATH|No|The location of logs inside of the docker image||
|FM_GOVERNANCE_CA_FILE|Yes|File name and path to governance certificate||
|FM_GOVERNANCE_CA_PASSWORD|Yes| Governance certificate password||
|FM_HTTPS_USE_CUSTOM_CERT|No|Flag which informs FlowManager that you are using custom certificates|`true`|
|FM_HTTPS_KEYSTORE|Yes|File name and path to HTTPS certificate||
|FM_HTTPS_CERT_ALIAS|No|Alias of the HTTPS certificate||
|FM_HTTPS_KEYSTORE_PASSWORD|Yes|HTTPS certificate password||
|FM_HTTPS_DISABLED|No|Set on `true` if the ssl requests are handled by a gateway (SSL termination)|`false`|
|FM_CFT_SHARED_SECRET|No|FlowManager's shared secret||
|FM_CFT_UPDATES_PATH|Yes|The path needed to update CFT plugin||
|FM_DATABASE_HOST|No|MongoDB host name|`mongodb`|
|FM_DATABASE_PORT|No|MongoDB port|`27017`|
|FM_DATABASE_USER_NAME|Yes|MongoDB user used for FlowManager||
|FM_DATABASE_USER_PASSWORD|Yes|MongoDB user's password used for FlowManager||
|FM_DATABASE_USE_SSL|No| MongoDB option for use of SSL|`false`|
|FM_DATABASE_CERTIFICATES|No|MongoDB truststore (At the moment we support only jks)||
|FM_DATABASE_AUTHSOURCE|No|The database in which the MongoDB user (`FM_DATABASE_USER_NAME`) was created. If not set, it means that the user belongs to the FlowManager database (`FM_DATABASE_NAME`).||
|FM_DATABASE_AUTH_MECHANISM|No|The client authentication mechanism. Possible values: `LDAP`, `SCRAM_SHA1`, `SCRAM_SHA256`. If not set, the default mongo client authentication mechanism will be used (`SCRAM_SHA1`). If LDAP is used, the `FM_DATABASE_AUTHSOURCE` should not be set because in this case its default value is `$external`.||
|FM_ST_PLUGIN_CA_FILE|Yes|File name and path to the CA of ST plugin||
|FM_ST_PLUGIN_PUBLIC_KEY|Yes|File name and path to the public key of ST plugin||
|FM_METRICS_ENABLED|No|Enable metrics for Prometheus|`false`|
|FM_ST_PLUGIN_DISABLED|No|Disable ST Plugin|`false`|
|FM_JVM_XMX|No|JVM maximum memory allocation pool|`2G`|
|FM_JVM_XMS|No|JVM maximum memory allocation pool|`512M`|
|FM_JVM_XMN|No|JVM size of the heap for the young generation|`768M`|

## MongoDB

|**Parameter**|**Mandatory**|**Description**|**Default value**|
|-------------|------------|---------------|-----------------|
|MONGO_IMAGE_URL*|No|URL from where you want to get the image|`mongo`|
|MONGO_IMAGE_VERSION*|No|DB version based on docker image|`4.2`|
|MONGO_INTERNAL_PORT|No|DB port|`27017`|
|MONGO_EXTERNAL_PORT|No|DB external container port|`27017`|
|MONGO_INITDB_ROOT_USERNAME|Yes|DB Super user||
|MONGO_INITDB_ROOT_PASSWORD|Yes|DB Super password||
|MONGO_APP_DATABASE|Yes|Database name for the application||
|MONGO_APP_USER|Yes|Database user for the application||
|MONGO_APP_PASS|Yes|Database password for the application||
|MONGO_BIND_IP|No|Bind to all IPv4 and IPv6 addresses|`0.0.0.0`|
|MONGO_CA_FILE|No|Contains the root certificate chain from the Certificate Authority||
|MONGO_PEM_KEY_FILE|No|Contains both the TLS/SSL certificate and key||

## Redis

|**Parameter**|**Mandatory**|**Description**|**Default value**|
|-------------|------------|---------------|-----------------|
|FM_REDIS_ENABLED|No|Specifies if Redis is enabled|`false`|
|FM_REDIS_HOSTNAME|No|hostname of the Redis instance||
|FM_REDIS_PORT|No|The port of the connection between FM and Redis|`6379`|
|FM_REDIS_AUTH_ENABLED|No|Specifies if the Redis instance is protected by a password|`false`|
|FM_REDIS_PASSWORD|No|The password needed for authentication to Redis||
|FM_REDIS_USER|No|Only for Redis 6.x; it should be empty if the default user is used||
|FM_REDIS_SSL_ENABLED|No|Specifies if Redis runs with SSL|`false`|
|FM_REDIS_SSL_CA|No|Path to the CA certificate used by Redis||


## SecureTransport Plugin

|**Parameter**|**Mandatory**|**Description**|**Default value**|
|-------------|------------|---------------|-----------------|
|ST_FM_PLUGIN_IMAGE_URL*|No|URL from where you get the image|`axway/st-fm-plugin`|
|ST_FM_PLUGIN_IMAGE_VERSION*|Yes|ST plugin Docker image version||
|ST_FM_PLUGIN_HOST|Yes|The public hostname of the SecureTransport plugin|`st-fm-plugin`|
|ST_FM_PLUGIN_PORT|Yes|The public port of SecureTransport plugin|`8899`|
|ST_FM_PLUGIN_SHORT_NAME|Yes|The short name of the SecureTransport plugin used for the registration|`ST`|
|ST_FM_PLUGIN_ST_SKIP_HOSTNAME_VERIFICATION|Yes|Skip the SecureTransport hostname verification when establishing a connection to the SecureTransport server|`true`|
|ST_FM_PLUGIN_FM_FQDN|Yes|The fully qualified domain name of Flow Manager||
|ST_FM_PLUGIN_FM_HOST|Yes|The public hostname of Flow Manager|`flowmanager`|
|ST_FM_PLUGIN_FM_PORT|Yes|The general UI port used to access the Flow Manager|`8081`|
|ST_FM_PLUGIN_FM_DEPLOYMENT_MODE|Yes|-|`premise`|
|ST_FM_PLUGIN_SHARED_SECRET|Yes|Path to file containing a long string that would be used for sensitive payload encryption between FM and the plugin||
|ST_FM_PLUGIN_FM_GOV_CA_FULL_CHAIN|Yes|CA bundle file path location of Flow Manager Governance CA||
|ST_FM_PLUGIN_SERVER_PRIVATE_KEY_PEM|Yes|File path location to the Private key of the ST FM plugin||
|ST_FM_PLUGIN_CERT_PEM|Yes|File path location of the Public certificate of the ST FM plugin||
|ST_FM_PLUGIN_SERVER_CA_FULL_CHAIN|Yes|The CA bundle file of the ST FM plugin||
|ST_FM_PLUGIN_JWT_KEY|Yes|Path to a RSA private key for signing requests to the Flow Manager||
|ST_FM_PLUGIN_REJECT_UNAUTHORIZED_CONNECTION|No|Enable strict TLS verification|`true`|
|ST_FM_PLUGIN_DATABASE_HOST|Yes|The database host|`mongodb`|
|ST_FM_PLUGIN_DATABASE_PORT|Yes|The database port|`27017`|
|ST_FM_PLUGIN_DATABASE_NAME|Yes|The application database name||
|ST_FM_PLUGIN_DATABASE_USER_NAME|Yes|The application database user name||
|ST_FM_PLUGIN_DATABASE_USER_PASSWORD|Yes|The user password used for connecting to the database||
|ST_FM_PLUGIN_DATABASE_CONNECTION_RETRIES|Yes|The number of attempts to reconnect to the database|`15`|
|ST_FM_PLUGIN_DATABASE_CONNECTION_RETRY_INTERVAL|Yes|Server wait time in seconds between retries|`60`|
|ST_FM_PLUGIN_DATABASE_USE_SSL|Yes|Enable TLS security in database connection|`false`|
|ST_FM_PLUGIN_DATABASE_CERTIFICATES|No| It must contain the root and intermediate certificates of the database SSL certificate||


***
*Parameters for docker compose only.
