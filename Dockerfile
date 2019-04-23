FROM centos:7.6.1810 as builder

RUN echo "Adding username [axway] to the system." && \
    groupadd -r axway && \
    useradd -r -g axway axway && \
    mkdir -p /opt/axway/FlowCentral/runtime && \
    mkdir -p /opt/axway/FlowCentral/logs && \
    mkdir -p /opt/axway/FlowCentral/conf/license && \
    mkdir -p /opt/axway/configs && \
    mkdir -p /opt/axway/FlowCentral/data/keys/com.axway.nodes.ume && \
    mkdir -p /home/axway && \
    chown -R axway:axway /home/axway && \
    chmod -R 777 /home/axway && \
    chown -R axway:axway /opt/axway && \
    chmod -R 777 /opt/axway


# install FC OS prerequisites
RUN yum -y update && \
    yum install --quiet -y wget unzip zip

ARG FC_URL="http://repository4.ecd.axway.int/content/repositories/cg-snapshot/com/axway/flowcentral/lightdistrib/flowcentral-delivery-light-distrib/"
# SNAPSHOT VERSION OR RELEASE NUMBER
ARG FC_RELEASE_TYPE="<fc_release_type>"
# FC ARTIFACT
ARG FC_ARTIFACT="<fc_artifact>"

ARG FC_CFT_PLUGIN_URL="http://swf-artifactory.lab1.lab.ptx.axway.int/artifactory/com.axway.cft-release//com/axway/cft/cg/plugin/cft-cg-plugin-distrib/"
# SNAPSHOT VERSION OR RELEASE NUMBER
ARG FC_CFT_RELEASE_TYPE="<fc_cft_release_type>"
# FC_CFT_PLUGIN ARTIFACT
ARG FC_CFT_PLUGIN_ARTIFACT="<fc_cft_plugin>"

ARG FC_ST_PLUGIN_URL="http://swf-artifactory.lab1.lab.ptx.axway.int:80/artifactory/com.axway.cg-snapshot/com/axway/securetransport/securetransport-plugin-distrib/"
#SNAPSHOT VERSION OR RELEASE NUMBER
ARG FC_ST_RELEASE_TYPE="<fc_st_release_type>"
# FC_ST_PLUGIN ARTIFACT
ARG FC_ST_PLUGIN_ARTIFACT="<fc_st_plugin>"

RUN wget -nc -r --accept "*zip" --level 1 -nH --cut-dirs=100 "$FC_URL$FC_RELEASE_TYPE$FC_ARTIFACT" -P /home/axway/FC_KIT && \
    wget -nc -r --accept "*zip" --level 1 -nH --cut-dirs=100 "$FC_CFT_PLUGIN_URL$FC_CFT_RELEASE_TYPE$FC_CFT_PLUGIN_ARTIFACT" -P /home/axway/CFT_PLUGIN_KIT && \
    wget -nc -r --accept "*zip" --level 1 -nH --cut-dirs=100 "$FC_ST_PLUGIN_URL$FC_ST_RELEASE_TYPE$FC_ST_PLUGIN_ARTIFACT" -P /home/axway/ST_PLUGIN_KIT && \
    unzip /home/axway/FC_KIT/$FC_ARTIFACT -d /opt/axway/FlowCentral/ && \
    unzip /home/axway/CFT_PLUGIN_KIT/$FC_CFT_PLUGIN_ARTIFACT -d /opt/axway/FlowCentral/ && \
    unzip /home/axway/ST_PLUGIN_KIT/$FC_ST_PLUGIN_ARTIFACT -d /opt/axway/FlowCentral/ && \
    rm -rf /opt/axway/FlowCentral/resources/*
    


FROM centos:7.6.1810

COPY --from=builder  --chown=axway:axway /opt/axway/FlowCentral /opt/axway/FlowCentral

RUN echo "Adding username [axway] to the system." && \
    groupadd -r axway && \
    useradd -r -g axway axway
    
COPY resources /opt/axway/resources
COPY scripts/start.sh /opt/axway/scripts/start.sh

RUN yum -y update && \
    yum install --quiet -y java-1.8.0-openjdk-1.8.0.201.b09 && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    chmod -R 777 /opt/axway/ && \
    chmod -R 777 /tmp && \
    echo "*       hard    nproc   65535" >> /etc/security/limits.conf && \
    echo "*       soft    nproc   65535" >> /etc/security/limits.conf && \
    echo "*       hard    nofile   65535" >> /etc/security/limits.conf && \
    echo "*       soft    nofile   65535" >> /etc/security/limits.conf

RUN usermod -u 1000 axway

WORKDIR /opt/axway

USER axway

CMD ["/opt/axway/scripts/start.sh"]
