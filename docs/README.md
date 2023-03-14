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
|FM_UNMANAGED_PRODUCT_ENABLED|No|Enables the Unmanaged Product plugin in Flow Manager|`false`|

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

## SAML

|**Parameter**|**Mandatory**|**Description**|**Default value**|
|-------------|------------|---------------|-----------------|
|FM_IDP_CONFIGURATION|No|Specifies if the IDP used is `internal` or `custom`|`internal`|
|FM_IDP_ENTITY_ID|Yes|The clientId from the SAML IDP that will be used when sending authentication requests.||
|FM_IDP_SSO_DESCRIPTOR|Yes|Path or URL to the IDP descriptor.||
|FM_IDP_HTTPS_ENABLED|mandatory if FM_IDP_SSO_DESCRIPTOR is an URL|Specifies if IDP uses SSL.|`true`|
|FM_IDP_SSL_CERTIFICATE|mandatory if FM_IDP_HTTPS_ENABLED is `true`|Path to the SSL certificate of IDP.||
|FM_IDP_VERIFY_METADATA_SIGNATURE|Yes|Enable or disable IDPSSODescriptor metadata configuration signature verification.|`false`|
|FM_IDP_METADATA_RELOAD_DELAY|mandatory if FM_IDP_SSO_DESCRIPTOR is an URL|The Identity Provider metadata IDPSSODescriptor reload delay in minutes (only for metadata URL).|`10`|
|FM_IDP_SIGN_SAML_MESSAGES|Yes|Specifies if the the Service provider will sign all SAML messages sent to the Identity Provider.|`true`|
|FM_IDP_SIGN_KEYSTORE|mandatory if FM_IDP_SIGN_SAML_MESSAGES is `true`|This property contains the CA and Signing Certificate for signing SAML messages sent to the Identity Provider||
|FM_IDP_SIGN_KEYSTORE_PASSWORD|mandatory if IDP certificate is encrypted|This property contains the password for the private key for the Identity Provider signing certificate, if it is encrypted.||
|FM_IDP_SIGNATURE_ALGORITHM|mandatory if FM_IDP_SIGN_SAML_MESSAGES is `true`|The metadata signature algorithm used to sign messages sent to SAML Identity Provider.|`sha-256`|
|FM_IDP_CANONICALIZATION_ALGORITHM|mandatory if FM_IDP_SIGN_SAML_MESSAGES is `true`|The metadata canonicalization algorithm used to sign messages sent to SAML Identity Provider.|`Exclusive`|
|FM_IDP_SIGN_AUTHENTICATION_REQUEST|mandatory if FM_IDP_SIGN_SAML_MESSAGES is `true`|Enable or disable Service Provider to sign all authentication requests.|`true`|
|FM_IDP_SIGN_LOGOUT_REQUEST|mandatory if FM_IDP_SIGN_SAML_MESSAGES is `true`|Enable or disable Service Provider to sign all logout requests.|`true`|
|FM_IDP_SIGN_LOGOUT_RESPONSE|mandatory if FM_IDP_SIGN_SAML_MESSAGES is `true`|Enable or disable Service Provider to sign all logout responses.|`true`|
|FM_IDP_SAML_RESPONSE_BINDING|Yes|Service provider response binding.|`HTTP-POST`|
|FM_IDP_UNSIGNED_ASSERTIONS|Yes|Service Provider will accept or not unsigned assertions from the Identity Provider|`false`|
|FM_IDP_VERIFY_ASSERTION_EXPIRATION|Yes|Check assertion expiration on the service provider. |`true`|
|FM_IDP_FM_ACCESS_MANAGER_USERNAME|Yes|Username of the admin user that will be able to map Identity Provider roles to FM roles.||

Note: all SAML parameters are mandatory if FM_IDP_CONFIGURATION is set on `custom`.

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
