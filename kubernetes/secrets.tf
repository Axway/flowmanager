resource "kubernetes_secret" "mongodb-secret-env-vars" {
  metadata {
    name = "mongodb-secret-env-vars"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    mongodb-passwords = "${trimspace(data.local_file.mongodb-fm-user-password.content)},${trimspace(data.local_file.mongodb-fm-st-plugin-user-password.content)}"
    mongodb-root-password = "${trimspace(data.local_file.mongodb-root-password.content)}"
    mongodb-metrics-password = "" # "${data.local_file..content}"
    mongodb-replica-set-key = "${trimspace(data.local_file.mongodb-replica-set-key.content)}"
  }

}


resource "kubernetes_secret" "mongodb-secret-files" {
  metadata {
    name = "mongodb-secret-files"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    mongodb-ca-cert = "${data.local_file.mongodb-ca-pem.content}"
    mongodb-ca-key = "${data.local_file.mongodb-ca-key-pem.content}"
    mongodb-client-pem = ""
    governanceca-p12 = "${data.local_file.fm-governance-ca-pkcs12.content}"
  }

}

resource "kubernetes_secret" "flowmanager-core-security-files" {
  metadata {
    name = "flowmanager-core-security-files"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  binary_data = {
    "governanceca.p12" = filebase64("${path.module}/resources/kubernetes-secrets/flowmanager-core/files/fm-governance-ca.p12")
    "mongodb-ca.pem" = base64encode("${data.local_file.mongodb-ca-pem.content}")
    "st-fm-plugin-ca.pem" = base64encode("${data.local_file.st-fm-plugin-server-ca-full-chain-pem.content}")
    "st-fm-plugin-public-key.pem" = base64encode("${data.local_file.st-fm-plugin-server-public-key-pem.content}")
    "fm-core-jwt-private-key.pem" = base64encode("${data.local_file.fm-core-jwt-private-key-pem.content}")
    "fm-cftplugin-jwt-private-key.pem" = base64encode("${data.local_file.fm-cftplugin-jwt-private-key-pem.content}")
    "fm-bridge-jwt-public-key.pem" = base64encode("${data.local_file.fm-bridge-jwt-public-key-pem.content}")
  }

}

resource "kubernetes_secret" "flowmanager-core-security-env-vars" {
  metadata {
    name = "flowmanager-core-security-env-vars"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    FM_GENERAL_ENCRYPTION_KEY = "${trimspace(data.local_file.fm-general-encryption-key.content)}"
    FM_GOVERNANCE_CA_PASSWORD = "${trimspace(data.local_file.fm-governance-ca-password.content)}"
    FM_DATABASE_USER_PASSWORD = "${trimspace(data.local_file.mongodb-fm-user-password.content)}"
  }

}

resource "kubernetes_secret" "flowmanager-core-license" {
  metadata {
    name = "flowmanager-core-license"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    "license.xml" = "${data.local_file.fm-license.content}"
  }

}


resource "kubernetes_secret" "flowmanager-st-plugin-security-files" {
  metadata {
    name = "flowmanager-st-plugin-security-files"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    "st-fm-plugin-shared-secret" = "${data.local_file.st-fm-plugin-shared-secret.content}"
    "governanceca.pem" = "${data.local_file.fm-governance-ca-full-chain-public-pem.content}"
    "st-fm-plugin-cert-key.pem" = "${data.local_file.st-fm-plugin-server-cert-key-pem.content}"
    "st-fm-plugin-cert.pem" = "${data.local_file.st-fm-plugin-server-cert-pem.content}"
    "st-fm-plugin-ca.pem" = "${data.local_file.st-fm-plugin-server-ca-full-chain-pem.content}"
    "private-key" = "${data.local_file.st-fm-plugin-jwt-key.content}"
    "mongodb.pem" = "${data.local_file.mongodb-ca-pem.content}"
  }

}

resource "kubernetes_secret" "flowmanager-st-plugin-security-env-vars" {
  metadata {
    name = "flowmanager-st-plugin-security-env-vars"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    ST_FM_PLUGIN_DATABASE_USER_PASSWORD = "${trimspace(data.local_file.mongodb-fm-st-plugin-user-password.content)}"
  }

}

resource "kubernetes_secret" "flowmanager-bridge-security-files" {
  metadata {
    name = "flowmanager-bridge-security-files"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    "dosa.json"            = "${data.local_file.fm-bridge-jwt-dosa-json.content}"
    "dosa-key.pem"         = "${data.local_file.fm-bridge-jwt-private-key-pem.content}"
    "fm-bridge-chain.pem"  = "${data.local_file.fm-bridge-cert-chain-pem.content}"
    "fm-bridge-key.pem"    = "${data.local_file.fm-bridge-cert-key-pem.content}"
    "fm-governance-ca.pem" = "${data.local_file.fm-governance-ca-full-chain-pem.content}"
    "governanceca.p12" = filebase64("${path.module}/resources/kubernetes-secrets/flowmanager-core/files/fm-governance-ca.p12")
  }

}

resource "kubernetes_secret" "flowmanager-bridge-security-env-vars" {
  metadata {
    name = "flowmanager-bridge-security-env-vars"
    namespace = var.fm-namespace
  }

  type = "Opaque"

  data = {
    JWT_KEY_PASSWORD = "${trimspace(data.local_file.fm-bridge-jwt-private-key-password.content)}"
    BRIDGE_KEY_PASSWORD = "${trimspace(data.local_file.fm-bridge-cert-key-password.content)}"
  }

}

# resource "kubernetes_secret" "ingress-tls-security-files" {
#   metadata {
#     name = "ingress-tls-security-files"
#     namespace = var.fm-namespace
#   }

#   type = "Opaque"

#   data = {
#     "tls.crt" = "${data.local_file.ingress-tls-ui-cert-pem.content}"
#     "tls.key" = "${data.local_file.ingress-tls-ui-cert-key-pem.content}"
#   }

# }

resource "kubernetes_secret" "registry-credentials" {
  metadata {
    name = "registry-credentials"
    namespace = var.fm-namespace
  }

  count = var.registry_server != null ? 1 : 0

  type = "kubernetes.io/dockerconfigjson"

  data = { 
    ".dockerconfigjson" = jsonencode({ 
      auths = { 
        "${var.registry_server}" = { 
          "username" = var.registry_username 
          "password" = var.registry_password 
          "auth" = base64encode("${var.registry_username}:${var.registry_password}") 
        } 
      } 
    }) 
  }
}
