# From cluster configuration
fm-namespace = "appspace-fm-sample"

# Helm release names
mft-fm-helm-release-name = "mft-flowmanager-release"
mft-mongodb-helm-release-name = "mft-mongodb-release"

# public FQDN
fm-core-public-fqdn = "flowmanager-fm-sample.fm.axwaytest.net"
fm-bridge-public-fqdn = "fm-bridge-fm-sample.fm.axwaytest.net"

# Helm Charts
# This will be replaced by an Axway location
helmchart-bitnami-mongodb-repo = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami" 
helmchart-bitnami-mongodb-tag = "13.5.0"

helmchart-mft-flomanager-repo = "mft-helm-release"
helmchart-mft-flomanager-tag = "2.0.20230526"

# Mongo DB Image
image-bitnami-mongodb-tag = "5.0.22-debian-11-r5"

# Flowmanager Images
image-mft-fm-core-repo = "flowmanager-docker-snapshot-buch.<TBD>/flowmanager_release"
image-mft-fm-core-tag = "REPLACEME"
image-mft-fm-st-plugin-repo = "flowmanager-stplugin-docker-release.<TBD>/st-fm-plugin"
image-mft-fm-st-plugin-tag = "REPLACEME"
image-mft-fm-bridge-repo = "flowmanager-bridge-docker-release.<TBD>/release"
image-mft-fm-bridge-tag = "REPLACEME"

# Registry details
registry_server = "REPLACEME"
registry_username = "REPLACEME"
registry_password = "REPLACEME"