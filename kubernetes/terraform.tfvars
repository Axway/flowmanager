# From cluster configuration
fm-namespace = "flowmanager"

# public FQDN
fm-core-public-fqdn = "flowmanager-fm-sample.fm.axwaytest.net"
fm-bridge-public-fqdn = "fm-bridge-fm-sample.fm.axwaytest.net"

# FM helm chart
mft-fm-helm-release-name = "mft-flowmanager-release"
helmchart-mft-flomanager-repo = "mft-helm-release"
helmchart-mft-flomanager-tag = "2.0.20230526"

# Flowmanager Images
image-mft-fm-core-repo = "flowmanager-docker-release.artifactory.axway.com/flowmanager_release"
image-mft-fm-core-tag = "REPLACEME"
image-mft-fm-st-plugin-repo = "flowmanager-stplugin-docker-release.artifactory.axway.com/st-fm-plugin"
image-mft-fm-st-plugin-tag = "REPLACEME"
image-mft-fm-bridge-repo = "flowmanager-bridge-docker-release.artifactory.axway.com/release"
image-mft-fm-bridge-tag = "REPLACEME"

#MongoDB toggle
#true = external MongoDB
#false = managed MongoDB
#Depending on the option, you can comment out the other MongoDB related variables
external-mongodb = false

#Managed MongoDB
image-bitnami-mongodb-tag = "6.0.13-debian-11-r21"
mft-mongodb-helm-release-name = "mft-mongodb-release"
helmchart-bitnami-mongodb-repo = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami" 
helmchart-bitnami-mongodb-tag = "13.5.0"

#External MongoDB
# mongodb-replica-set-name = "rs0"
# mongodb-fm-core-database-username = "flowmanageruser"
# mongodb-fm-st-plugin-database-username = "stpluginuser"
# mongodb-fm-core-database-name = "flowmanager"
# mongodb-fm-st-plugin-database-name = "stplugin"
# mongodb-fm-endpoints = "REPLACE:27017"

# Registry details
registry_server = "REPLACEME"
registry_username = "REPLACEME"
registry_password = "REPLACEME"