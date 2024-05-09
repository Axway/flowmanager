# ##################################
# Database - MongoDB
# ##################################

data "local_file" "mongodb-ca-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/mongodb/files/fm-mongodb-ca.pem"
}

data "local_file" "mongodb-ca-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/mongodb/files/fm-mongodb-ca-key.pem"
}

# data "local_file" "mongodb-certificate-pem" {
#    filename = "${path.module}/resources/kubernetes-secrets/mongodb/files/mongodb-cert-and-key.pem"
#  
# }

data "local_file" "mongodb-fm-user-password" {
   filename = "${path.module}/resources/kubernetes-secrets/mongodb/vars/mongodb-fm-user-password" 
}

resource "random_password" "mongodb-fm-user-password" { 
   length = 12
   special = true 
   override_special = "-_" 
}

data "local_file" "mongodb-fm-st-plugin-user-password" {
   filename = "${path.module}/resources/kubernetes-secrets/mongodb/vars/mongodb-fm-st-plugin-user-password"
}

resource "random_password" "mongodb-fm-st-plugin-user-password" { 
   length = 12
   special = true 
   override_special = "-_" 
}

data "local_file" "mongodb-root-password" {
   filename = "${path.module}/resources/kubernetes-secrets/mongodb/vars/mongodb-root-password"
}

resource "random_password" "mongodb-root-password" { 
   length = 12
   special = true 
   override_special = "-_" 
}

data "local_file" "mongodb-replica-set-key" {
   filename = "${path.module}/resources/kubernetes-secrets/mongodb/vars/mongodb-replica-set-key"
}

resource "random_password" "mongodb-replica-set-key" { 
   length = 16
   special = false 
}

# ##################################
# Products - FlowManager Core
# ##################################

data "local_file" "fm-general-encryption-key" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/vars/fm-general-encryption-key"
}

data "local_file" "fm-governance-ca-password" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/vars/fm-governance-ca-password"
}
data "local_file" "fm-license" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/files/license.xml"
}
data "local_file" "fm-governance-ca-pkcs12" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/files/fm-governance-ca.p12"
}
data "local_file" "fm-governance-ca-full-chain-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/files/fm-governance-ca-full-chain.pem"
}
data "local_file" "fm-governance-ca-full-chain-public-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/files/fm-governance-ca-cert.pem"
}
data "local_file" "fm-core-jwt-private-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/files/fm-core-jwt-private-key.pem"
}
data "local_file" "fm-cftplugin-jwt-private-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/files/fm-cftplugin-jwt-private-key.pem"
}
data "local_file" "fm-user-initial-password" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-core/vars/fm-user-initial-password"
}


# ##################################
# Products - FlowManager ST Plugin
# ##################################
data "local_file" "st-fm-plugin-server-public-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-st-plugin/files/st-fm-plugin-server-public-key.pem"
}
data "local_file" "st-fm-plugin-server-cert-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-st-plugin/files/st-fm-plugin-server-cert-key.pem"
}
data "local_file" "st-fm-plugin-server-cert-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-st-plugin/files/st-fm-plugin-server-cert.pem"
}
data "local_file" "st-fm-plugin-server-ca-full-chain-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-st-plugin/files/st-fm-plugin-server-ca-full-chain.pem"
}
data "local_file" "st-fm-plugin-jwt-key" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-st-plugin/files/st-fm-plugin-jwt-private-key.pem"
}

data "local_file" "st-fm-plugin-shared-secret" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-st-plugin/vars/st-fm-plugin-shared-secret"
}

# ##################################
# Products - FlowManager Bridge
# ##################################

data "local_file" "fm-bridge-jwt-public-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-bridge/files/fm-bridge-jwt-public-key.pem"
}

data "local_file" "fm-bridge-jwt-private-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-bridge/files/fm-bridge-jwt-private-key.pem"
}

data "local_file" "fm-bridge-cert-chain-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-bridge/files/fm-bridge-cert-chain.pem"
}

data "local_file" "fm-bridge-cert-key-pem" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-bridge/files/fm-bridge-cert-key.pem"
}

data "local_file" "fm-bridge-jwt-dosa-json" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-bridge/files/fm-bridge-jwt-dosa.json"
}

data "local_file" "fm-bridge-cert-key-password" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-bridge/vars/fm-bridge-cert-key-password"
}

data "local_file" "fm-bridge-jwt-private-key-password" {
   filename = "${path.module}/resources/kubernetes-secrets/flowmanager-bridge/vars/fm-bridge-jwt-private-key-password"
}

# ##################################
# Ingress TLS
# ##################################
# data "local_file" "ingress-tls-ui-cert-pem" {
#    filename = "${path.module}/ingress/tls/ui-cert-pem"
# }

# data "local_file" "ingress-tls-ui-cert-key-pem" {
#    filename = "${path.module}/ingress/tls/ui-cert-key-pem"
# }