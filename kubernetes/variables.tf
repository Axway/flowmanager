variable "fm-namespace" {
  type = string
  description = "Flow manager's namespace"
  default = "flowmanager"
}

variable "fm-core-public-fqdn" {
  type = string
  description = "FlowManager Public FQDN Hostname"
}

variable "fm-bridge-public-fqdn" {
  type = string
  description = "FlowManager Bridge Public FQDN Hostname"
}

variable "cluster-domain" {
  type = string
  description = "demain name of the cluster."
  default = "cluster.local"
}

variable "mft-fm-helm-release-name" {
  type = string
  description = "Name of the MFT flow manager realease."
  default = "mft-flowmanager-release"
}

variable "mft-mongodb-helm-release-name" {
  type = string
  description = "Name of the MFT MongoDb realease."
  default = "mft-mongodb-release"
}

variable "helmchart-bitnami-mongodb-repo" {
  type = string
  description = "MongoDB Helm Chart repository"
  default = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
}
variable "helmchart-bitnami-mongodb-tag" {
  type = string
  description = "MongoDB Helm Chart tag"
  default = "12.1.27"
}

variable "helmchart-mft-flomanager-repo" {
  type = string
  description = "MongoDB Helm Chart repository"
  default = "mft-realease-repo"
}
variable "helmchart-mft-flomanager-tag" {
  type = string
  description = "MongoDB Helm Chart tag"
  default = "0.2.0"
}

variable "image-bitnami-mongodb-tag" {
  type = string
  description = "MongoDB image tag"
  default = "4.2.21-debian-10-r8"
}

variable "image-mft-fm-core-repo" {
  type = string
  description = "FlowManager Core image repository"
  default = "flowmanager-docker-release.artifactory.axway.com/flowmanager_release"
}
variable "image-mft-fm-core-tag" {
  type = string
  description = "FlowManager Core image tag"
  default = "2.0.2211021817"
}

variable "image-mft-fm-st-plugin-repo" {
  type = string
  description = "FlowManager ST plugin image repository"
  default = "flowmanager-stplugin-docker-snapshot.artifactory.axway.com/dev/nninov-trd-6801"
}
variable "image-mft-fm-st-plugin-tag" {
  type = string
  description = "FlowManager ST plugin image tag"
  default = "202212011235"
}

variable "image-mft-fm-bridge-repo" {
  type = string
  description = "FlowManager Bridge image repository"
  default = "flowmanager-bridge-docker-release.artifactory.axway.com/release"
}
variable "image-mft-fm-bridge-tag" {
  type = string
  description = "FlowManager Bridge image tag"
  default = "release-20221109"
}

variable "mongodb-replica-set-name" {
  type = string
  description = "(Optional) MongDB Replica Set Name"
  default = "rs0"
}
variable "mongodb-fm-core-database-username" {
  type = string
  description = "(Optional) MongoDB Flow Manager Database Username"
  default = "flowmanageruser"
}
variable "mongodb-fm-core-database-name" {
  type = string
  description = "(Optional) MongoDB Flow Manager Core Database Name"
  default = "flowmanager"
}
variable "mongodb-fm-st-plugin-database-username" {
  type = string
  description = "(Optional) MongoDB ST Plugin Database Username"
  default = "stpluginuser"
}
variable "mongodb-fm-st-plugin-database-name" {
  type = string
  description = "(Optional) MongoDB ST Plugin Database Name"
  default = "stplugin"
}

variable "registry_server" {
  type = string
  description = "(optional) Registry URL"
  default = null
}  
variable "registry_username" {
  type = string
  description = "(optional) Registry Username"
  default = null
}  
variable "registry_password" {
  type = string
  description = "(optional) Registry Password"
  default = null
}  