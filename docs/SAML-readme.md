# Activate SAML in Flow Manager

To activate SAML in Flow Manager, you need to update the configuration files as follows:

# 1. Docker-compose

The following parameters must be added in the [docker-compose.yml](/docker-compose/docker-compose.yml) file:<br/>
`docker-compose.yml`<br/>
  &ndash; FM_IDP_CONFIGURATION=\${FM_IDP_CONFIGURATION:-custom<br/>
  &ndash; FM_IDP_ENTITY_ID=\${FM_IDP_ENTITY_ID}<br/>
  &ndash; FM_IDP_SSO_DESCRIPTOR=\${FM_IDP_SSO_DESCRIPTOR}<br/>
  &ndash; FM_IDP_HTTPS_ENABLED=\${FM_IDP_HTTPS_ENABLED:-true}<br/>
  &ndash; FM_IDP_SSL_CERTIFICATE=\${FM_IDP_SSL_CERTIFICATE}<br/>
  &ndash; FM_IDP_VERIFY_METADATA_SIGNATURE=${FM_IDP_VERIFY_METADATA_SIGNATURE:-false}<br/>
  &ndash; FM_IDP_METADATA_RELOAD_DELAY=\${FM_IDP_METADATA_RELOAD_DELAY:-10}<br/>
  &ndash; FM_IDP_SIGN_SAML_MESSAGES=\${FM_IDP_SIGN_SAML_MESSAGES:-true}<br/>
  &ndash; FM_IDP_SIGN_KEYSTORE=\${FM_IDP_SIGN_KEYSTORE}<br/>
  &ndash; FM_IDP_SIGN_KEYSTORE_PASSWORD=\${FM_IDP_SIGN_KEYSTORE_PASSWORD}<br/>
  &ndash; FM_IDP_SIGNATURE_ALGORITHM=\${FM_IDP_SIGNATURE_ALGORITHM:-sha-256}<br/>
  &ndash; FM_IDP_CANONICALIZATION_ALGORITHM=\${FM_IDP_CANONICALIZATION_ALGORITHM:-Exclusive}<br/>
  &ndash; FM_IDP_SIGN_AUTHENTICATION_REQUEST=\${FM_IDP_SIGN_AUTHENTICATION_REQUEST:-true}<br/>
  &ndash; FM_IDP_SIGN_LOGOUT_REQUEST=\${FM_IDP_SIGN_LOGOUT_REQUEST:-true}<br/>
  &ndash; FM_IDP_SIGN_LOGOUT_RESPONSE=\${FM_IDP_SIGN_LOGOUT_RESPONSE:-true}<br/>
  &ndash; FM_IDP_SAML_RESPONSE_BINDING=\${FM_IDP_SAML_RESPONSE_BINDING:-HTTP-POST}<br/>
  &ndash; FM_IDP_UNSIGNED_ASSERTIONS=\${FM_IDP_UNSIGNED_ASSERTIONS:-false}<br/>
  &ndash; FM_IDP_VERIFY_ASSERTION_EXPIRATION=\${FM_IDP_VERIFY_ASSERTION_EXPIRATION:-true}<br/>

Next, the [.env](/docker-compose/env.template) file should be updated with the values of these parameters:<br/>
`.env`<br/>
&emsp;FM_IDP_ENTITY_ID=<br/>
&emsp;FM_IDP_SSO_DESCRIPTOR=<br/>
&emsp;FM_IDP_HTTPS_ENABLED=true<br/>
&emsp;FM_IDP_SSL_CERTIFICATE=/opt/axway/FlowManager/configs/\<name-of-the-ssl-cert><br/>
&emsp;FM_IDP_VERIFY_METADATA_SIGNATURE=false<br/>
&emsp;FM_IDP_METADATA_RELOAD_DELAY=10<br/>
&emsp;FM_IDP_SIGN_SAML_MESSAGES=true<br/>
&emsp;FM_IDP_SIGN_KEYSTORE=/opt/axway/FlowManager/configs/\<name-of-the-idp-keystore\><br/>
&emsp;FM_IDP_SIGN_KEYSTORE_PASSWORD=\<password-of-the-ipd-keystore\><br/>
&emsp;FM_IDP_SIGNATURE_ALGORITHM=sha-256<br/>
&emsp;FM_IDP_CANONICALIZATION_ALGORITHM=Exclusive<br/>
&emsp;FM_IDP_SIGN_AUTHENTICATION_REQUEST=true<br/>
&emsp;FM_IDP_SIGN_LOGOUT_REQUEST=true<br/>
&emsp;FM_IDP_SIGN_LOGOUT_RESPONSE=true<br/>
&emsp;FM_IDP_SAML_RESPONSE_BINDING=HTTP-POST<br/>
&emsp;FM_IDP_UNSIGNED_ASSERTIONS=true<br/>
&emsp;FM_IDP_VERIFY_ASSERTION_EXPIRATION=true<br/>

# 2. Podman

The same parameters as for docker-compose must be added in the [flowmanager.yml](/podman/flowmanager.yml) file, in the `flowmanager` container section:<br/>
`flowmanager.yml`<br/>
  &ndash; name: FM_IDP_CONFIGURATION<br/>
 &nbsp;&nbsp; value: "custom"<br/>
  &ndash; name: FM_IDP_ENTITY_ID<br/>
 &nbsp;&nbsp; value: ""<br/>
  &ndash; name: FM_IDP_SSO_DESCRIPTOR<br/>
 &nbsp;&nbsp; value: ""<br/>
  &ndash; name: FM_IDP_HTTPS_ENABLED<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SSL_CERTIFICATE<br/>
 &nbsp;&nbsp; value: "/opt/axway/FlowManager/configs/\<name-of-the-ssl-cert\>"<br/>
  &ndash; name: FM_IDP_VERIFY_METADATA_SIGNATURE<br/>
 &nbsp;&nbsp; value: "false"<br/>
  &ndash; name: FM_IDP_METADATA_RELOAD_DELAY<br/>
 &nbsp;&nbsp; value: "10"<br/>
  &ndash; name: FM_IDP_SIGN_SAML_MESSAGES<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SIGN_KEYSTORE<br/>
 &nbsp;&nbsp; value: "/opt/axway/FlowManager/configs/\<name-of-the-idp-keystore\>"<br/>
  &ndash; name: FM_IDP_SIGN_KEYSTORE_PASSWORD<br/>
 &nbsp;&nbsp; value: "\<password-of-the-ipd-keystore\>"<br/>
  &ndash; name: FM_IDP_SIGNATURE_ALGORITHM<br/>
 &nbsp;&nbsp; value: "sha-256"<br/>
  &ndash; name: FM_IDP_CANONICALIZATION_ALGORITHM<br/>
 &nbsp;&nbsp; value: "Exclusive"<br/>
  &ndash; name: FM_IDP_SIGN_AUTHENTICATION_REQUEST<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SIGN_LOGOUT_REQUEST<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SIGN_LOGOUT_RESPONSE<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SAML_RESPONSE_BINDING<br/>
 &nbsp;&nbsp; value: "HTTP-POST"<br/>
  &ndash; name: FM_IDP_UNSIGNED_ASSERTIONS<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_VERIFY_ASSERTION_EXPIRATION<br/>
 &nbsp;&nbsp; value: "true"<br/>

# 3. Kubernetes Standard files
The same parameters as for docker-compose must be added in the [patch.yml for single node](/kubernetes/standard/singlenode/patch.yml) or [patch.yml for multi node](/kubernetes/standard/multinode/patch.yml) file, in the `flowmanager` env section:<br/>
`flowmanager.yml`<br/>
  &ndash; name: FM_IDP_CONFIGURATION<br/>
 &nbsp;&nbsp; value: "custom"<br/>
  &ndash; name: FM_IDP_ENTITY_ID<br/>
 &nbsp;&nbsp; value: ""<br/>
  &ndash; name: FM_IDP_SSO_DESCRIPTOR<br/>
 &nbsp;&nbsp; value: ""<br/>
  &ndash; name: FM_IDP_HTTPS_ENABLED<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SSL_CERTIFICATE<br/>
 &nbsp;&nbsp; value: "/opt/axway/FlowManager/configs/\<name-of-the-ssl-cert\>"<br/>
  &ndash; name: FM_IDP_VERIFY_METADATA_SIGNATURE<br/>
 &nbsp;&nbsp; value: "false"<br/>
  &ndash; name: FM_IDP_METADATA_RELOAD_DELAY<br/>
 &nbsp;&nbsp; value: "10"<br/>
  &ndash; name: FM_IDP_SIGN_SAML_MESSAGES<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SIGN_KEYSTORE<br/>
 &nbsp;&nbsp; value: "/opt/axway/FlowManager/configs/\<name-of-the-idp-keystore\>"<br/>
  &ndash; name: FM_IDP_SIGN_KEYSTORE_PASSWORD<br/>
 &nbsp;&nbsp; value: "\<password-of-the-ipd-keystore\>"<br/>
  &ndash; name: FM_IDP_SIGNATURE_ALGORITHM<br/>
 &nbsp;&nbsp; value: "sha-256"<br/>
  &ndash; name: FM_IDP_CANONICALIZATION_ALGORITHM<br/>
 &nbsp;&nbsp; value: "Exclusive"<br/>
  &ndash; name: FM_IDP_SIGN_AUTHENTICATION_REQUEST<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SIGN_LOGOUT_REQUEST<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SIGN_LOGOUT_RESPONSE<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_SAML_RESPONSE_BINDING<br/>
 &nbsp;&nbsp; value: "HTTP-POST"<br/>
  &ndash; name: FM_IDP_UNSIGNED_ASSERTIONS<br/>
 &nbsp;&nbsp; value: "true"<br/>
  &ndash; name: FM_IDP_VERIFY_ASSERTION_EXPIRATION<br/>
 &nbsp;&nbsp; value: "true"<br/>
  
# 4. Helm
The same parameters as for docker-compose must be added in the [flowmanager.yaml](/kubernetes/helm/flowmanager.yaml) file, in the `flowmanager` variables section:<br/>
FM_IDP_CONFIGURATION: "custom"<br/>
FM_IDP_ENTITY_ID: ""<br/>
FM_IDP_SSO_DESCRIPTOR: ""<br/>
FM_IDP_HTTPS_ENABLED: "true"<br/>
FM_IDP_SSL_CERTIFICATE: "/opt/axway/FlowManager/configs/\<name-of-the-ssl-cert\>"<br/>
FM_IDP_VERIFY_METADATA_SIGNATURE: "false"<br/>
FM_IDP_METADATA_RELOAD_DELAY: "10"<br/>
FM_IDP_SIGN_SAML_MESSAGES: "true"<br/>
FM_IDP_SIGN_KEYSTORE: "/opt/axway/FlowManager/configs/\<name-of-the-idp-keystore\>"<br/>
FM_IDP_SIGN_KEYSTORE_PASSWORD: "\<password-of-the-ipd-keystore\>"<br/>
FM_IDP_SIGNATURE_ALGORITHM: "sha-256"<br/>
FM_IDP_CANONICALIZATION_ALGORITHM: "Exclusive"<br/>
FM_IDP_SIGN_AUTHENTICATION_REQUEST: "true"<br/>
FM_IDP_SIGN_LOGOUT_REQUEST: "true"<br/>
FM_IDP_SIGN_LOGOUT_RESPONSE: "true"<br/>
FM_IDP_SAML_RESPONSE_BINDING: "HTTP-POST"<br/>
FM_IDP_UNSIGNED_ASSERTIONS: "true"<br/>
FM_IDP_VERIFY_ASSERTION_EXPIRATION: "true"<br/>

**Note**: for more information regarding the values of the SAML parameters, check this [file](README.md) or the official documentation of Flow Manager. 
