
# resource "kubernetes_namespace" "flowmanager" {
#   metadata {
#     name = var.fm-namespace
#   }
# }

resource "helm_release" "mongodb" {
  name       = var.mft-mongodb-helm-release-name
  count      = var.external-mongodb ? 0 : 1

  # Cannot use recent bitnami manifest because of old mongodb version.
  # repository = "https://charts.bitnami.com/bitnami"
  repository = var.helmchart-bitnami-mongodb-repo
  chart      = "mongodb"
  version    = var.helmchart-bitnami-mongodb-tag

  # Some clean up option when something goes wrong
  cleanup_on_fail           = true
  atomic                    = true
  wait                      = true

  values = [
    "${file("helm/mongodb/mongo-customvalues.yaml")}"
  ]

  set {
    name  = "image.tag"
    value = var.image-bitnami-mongodb-tag
  }
  set {
    name  = "auth.replicaSetName"
    value = var.mongodb-replica-set-name
  }

  set {
    name  = "auth.usernames[0]"
    value = var.mongodb-fm-core-database-username
  }

  set {
    name  = "auth.usernames[1]"
    value = var.mongodb-fm-st-plugin-database-username
  }

    set {
    name  = "auth.databases[0]"
    value = var.mongodb-fm-core-database-name
  }

  set {
    name  = "auth.databases[1]"
    value = var.mongodb-fm-st-plugin-database-name
  }

  namespace = var.fm-namespace

  depends_on = [
    kubernetes_secret.mongodb-secret-files,
  ]
}

resource "helm_release" "flowmanager" {
  name       = var.mft-fm-helm-release-name
  # chart      = "./tmp/dev/flowmanager-2.0.20221116.tgz"

  # Cannot use recent bitnami manifest because of old mongodb version.
  # repository = "https://charts.bitnami.com/bitnami"
  repository = var.helmchart-mft-flomanager-repo
  chart      = "flowmanager"
  version    = var.helmchart-mft-flomanager-tag

  values = [
    "${file("helm/flowmanager/flowmanager-customvalues.yaml")}"
  ]


  # ######################################
  #  Service : FM Core
  # ######################################

  set {
    name  = "fm-core.container.image.repository"
    value = var.image-mft-fm-core-repo
  }

    set {
    name  = "fm-core.container.image.tag"
    value = var.image-mft-fm-core-tag
  }

  set {
    name  = "fm-core.container.env.variables.FM_GENERAL_FQDN"
    value = var.fm-core-public-fqdn
  }

    set {
    name  = "fm-core.container.env.variables.FM_INTERNAL_HOST"
    value = "${var.mft-fm-helm-release-name}-fm-core.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  set {
    name  = "fm-core.ingress.tls[0].hosts[0]"
    value = var.fm-core-public-fqdn
  }


  set {
    name  = "fm-core.ingress.hosts[0].host"
    value = var.fm-core-public-fqdn
  }

  set {
    name  = "fm-core.container.env.variables.FM_DATABASE_ENDPOINTS"
    value = (var.external-mongodb) ? var.mongodb-fm-endpoints : "${var.mft-mongodb-helm-release-name}-0.${var.mft-mongodb-helm-release-name}-headless.${var.fm-namespace}.svc.${var.cluster-domain}\\,${var.mft-mongodb-helm-release-name}-1.${var.mft-mongodb-helm-release-name}-headless.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  set {
    name  = "fm-core.container.env.variables.FM_ST_PLUGIN_HOST"
    value = "${var.mft-fm-helm-release-name}-fm-st-plugin.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  set {
    name  = "fm-core.container.env.variables.FM_DATABASE_NAME"
    value = var.mongodb-fm-core-database-name
  }

  set {
    name  = "fm-core.container.env.variables.FM_DATABASE_USER_NAME"
    value = var.mongodb-fm-core-database-username
  }

  set {
    name  = "fm-core.container.env.variables.FM_PROXY_HOST"
    value = "${var.mft-fm-helm-release-name}-fm-bridge.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  # ######################################
  #  Service : FM ST Plugin
  # ######################################

  set {
    name  = "fm-st-plugin.container.image.repository"
    value = var.image-mft-fm-st-plugin-repo
  }

    set {
    name  = "fm-st-plugin.container.image.tag"
    value = var.image-mft-fm-st-plugin-tag
  }

  set {
    name  = "fm-st-plugin.container.env.variables.ST_FM_PLUGIN_DATABASE_NAME"
    value = var.mongodb-fm-st-plugin-database-name
  }

  set {
    name  = "fm-st-plugin.container.env.variables.ST_FM_PLUGIN_DATABASE_USER_NAME"
    value = var.mongodb-fm-st-plugin-database-username
  }

  set {
    name  = "fm-st-plugin.container.env.variables.ST_FM_PLUGIN_HOST"
    value = "${var.mft-fm-helm-release-name}-fm-st-plugin.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  set {
    name  = "fm-st-plugin.container.env.variables.ST_FM_PLUGIN_FM_INTERNAL_HOST"
    # value = var.fm-core-public-fqdn
    value = "${var.mft-fm-helm-release-name}-fm-core.${var.fm-namespace}.svc.${var.cluster-domain}"
  }
  set {
    name  = "fm-st-plugin.container.env.variables.ST_FM_PLUGIN_FM_FQDN"
    # value = var.fm-core-public-fqdn
    value = "${var.mft-fm-helm-release-name}-fm-core.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  set {
    name  = "fm-st-plugin.container.env.variables.ST_FM_PLUGIN_DATABASE_ENDPOINTS"
    value = (var.external-mongodb) ? var.mongodb-fm-endpoints : "${var.mft-mongodb-helm-release-name}-0.${var.mft-mongodb-helm-release-name}-headless.${var.fm-namespace}.svc.${var.cluster-domain}\\,${var.mft-mongodb-helm-release-name}-1.${var.mft-mongodb-helm-release-name}-headless.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

   set {
    name  = "fm-st-plugin.container.env.variables.ST_FM_PLUGIN_SAAS_BRIDGE_HOST"
    value = "${var.mft-fm-helm-release-name}-fm-bridge.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  # ######################################
  #  Service : FM Bridge
  # ######################################

  set {
    name  = "fm-bridge.container.image.repository"
    value = var.image-mft-fm-bridge-repo
  }

  set {
    name  = "fm-bridge.container.image.tag"
    value = var.image-mft-fm-bridge-tag
  }

  set {
    name  = "fm-bridge.container.env.variables.FM_URL"
    # value = "https://var.fm-core-public-fqdn"
    value = "https://${var.mft-fm-helm-release-name}-fm-core.${var.fm-namespace}.svc.${var.cluster-domain}:8443"
  }

  set {
    name  = "fm-bridge.container.env.variables.DISCOVERY_URLS"
    #value = "https://${var.mft-fm-helm-release-name}-fm-bridge-0.${var.fm-namespace}.pod.${var.cluster-domain}:8443\\,https://${var.mft-fm-helm-release-name}-fm-bridge-1.${var.fm-namespace}.pod.${var.cluster-domain}:8443"
    value = "https://${var.mft-fm-helm-release-name}-fm-bridge.${var.fm-namespace}.svc.${var.cluster-domain}:8443"
    #value = "https://${var.mft-fm-helm-release-name}-fm-bridge-0.${var.fm-namespace}:8443\\,https://${var.mft-fm-helm-release-name}-fm-bridge-1.${var.fm-namespace}:8443"
  }

  set {
    name  = "fm-bridge.container.env.variables.WHITELIST"
    # value = var.fm-core-public-fqdn
    value = "${var.mft-fm-helm-release-name}-fm-core.${var.fm-namespace}.svc.${var.cluster-domain}"
  }

  set {
    name  = "fm-bridge.ingress.tls[0].hosts[0]"
    value = var.fm-bridge-public-fqdn
  }

  set {
    name  = "fm-bridge.ingress.hosts[0].host"
    value = var.fm-bridge-public-fqdn
  }

  # ######################################
  #  Image: registry credentials
  # ######################################
  set {
    name = "fm-core.container.image.imagePullSecretsName"
    value = var.registry_server != null ? "registry-credentials" : ""
  }

  set {
    name = "fm-st-plugin.container.image.imagePullSecretsName"
    value = var.registry_server != null ? "registry-credentials" : ""
  }

  set {
    name = "fm-bridge.container.image.imagePullSecretsName"
    value = var.registry_server != null ? "registry-credentials" : ""
  }

  namespace = var.fm-namespace

  depends_on = [
    kubernetes_secret.mongodb-secret-files,
    kubernetes_secret.flowmanager-core-security-files,
    kubernetes_secret.flowmanager-core-security-env-vars,
    kubernetes_secret.flowmanager-core-license,
    kubernetes_secret.flowmanager-st-plugin-security-files,
    kubernetes_secret.flowmanager-st-plugin-security-env-vars,
    kubernetes_secret.flowmanager-bridge-security-files,
    kubernetes_secret.flowmanager-bridge-security-env-vars,
    helm_release.mongodb,
  ]
}