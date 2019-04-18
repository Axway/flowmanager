FROM centos:7.6.1810 as builder

RUN echo "Adding username [axway] to the system." && \
    groupadd -r axway && \
    useradd -r -g axway axway && \
    mkdir -p /opt/axway/FlowCentral/runtime && \
    mkdir -p /opt/axway/FlowCentral/logs && \
    mkdir -p /opt/axway/FlowCentral/data/CGLicense && \
    mkdir -p /opt/axway/configs && \
    mkdir -p /opt/axway/FlowCentral/data/keys/com.axway.nodes.ume && \
    mkdir -p /home/axway && \
    chown -R axway:axway /home/axway && \
    chmod -R 777 /home/axway && \
    chown -R axway:axway /opt/axway && \
    chmod -R 777 /opt/axway


# install FC OS prerequisites
RUN yum -y update && \
    yum install --quiet -y wget unzip zip java-1.8.0-openjdk 

COPY resources /opt/axway/resources

#ARG FC_URL="http://repository4.ecd.axway.int/content/repositories/cg-snapshot/com/axway/flowcentral/lightdistrib/flowcentral-delivery-light-distrib/1.0.0-SNAPSHOT/"
# SNAPSHOT VERSION OR RELEASE NUMBER
#ARG FC_RELEASE_TYPE="<fc_release_type>"
# FC ARTIFACT
#ARG FC_ARTIFACT="flowcentral-delivery-light-distrib-1.0.0-20190415.221121-2.zip"

#ARG FC_CFT_PLUGIN_URL="http://swf-artifactory.lab1.lab.ptx.axway.int/artifactory/com.axway.cft-release//com/axway/cft/cg/plugin/cft-cg-plugin-distrib/"
# SNAPSHOT VERSION OR RELEASE NUMBER
#ARG FC_CFT_RELEASE_TYPE="1.24.0-SNAPSHOT"
# FC_CFT_PLUGIN ARTIFACT
ARG FC_CFT_PLUGIN_ARTIFACT="cft-cg-plugin-distrib-2.17.0-2-plugin.zip"

ARG FC_ST_PLUGIN_URL="http://swf-artifactory.lab1.lab.ptx.axway.int/artifactory/com.axway.cg-snapshot/com/axway/securetransport/securetransport-plugin-distrib/"
#SNAPSHOT VERSION OR RELEASE NUMBER
ARG FC_ST_RELEASE_TYPE="1.16.0-SNAPSHOT"
# FC_ST_PLUGIN ARTIFACT
ARG FC_ST_PLUGIN_ARTIFACT="securetransport-plugin-distrib-1.16.0-20190417.050518-8-plugin.zip"

RUN wget http://repository4.ecd.axway.int/content/repositories/cg-snapshot/com/axway/flowcentral/lightdistrib/flowcentral-delivery-light-distrib/1.0.0-SNAPSHOT/flowcentral-delivery-light-distrib-1.0.0-20190415.221121-2.zip -P /home/axway/FC_KIT && \
    wget http://swf-artifactory.lab1.lab.ptx.axway.int/artifactory/com.axway.cft-release//com/axway/cft/cg/plugin/cft-cg-plugin-distrib/2.17.0-2/cft-cg-plugin-distrib-2.17.0-2-plugin.zip -P /home/axway/CFT_PLUGIN_KIT && \
    wget http://swf-artifactory.lab1.lab.ptx.axway.int/artifactory/com.axway.cg-snapshot/com/axway/securetransport/securetransport-plugin-distrib/1.16.0-SNAPSHOT/securetransport-plugin-distrib-1.16.0-20190417.050518-8-plugin.zip -P /home/axway/ST_PLUGIN_KIT && \
    unzip /home/axway/FC_KIT/flowcentral-delivery-light-distrib-1.0.0-20190415.221121-2.zip -d /opt/axway/FlowCentral/ && \
    unzip /home/axway/CFT_PLUGIN_KIT/cft-cg-plugin-distrib-2.17.0-2-plugin.zip -d /opt/axway/FlowCentral/ && \
    unzip /home/axway/ST_PLUGIN_KIT/securetransport-plugin-distrib-1.16.0-20190417.050518-8-plugin.zip -d /opt/axway/FlowCentral/ && \
    rm -rf /opt/axway/FlowCentral/resources/*

FROM centos:7.6.1810

COPY --from=builder  /opt/axway /opt/axway

RUN echo "Adding username [axway] to the system." && \
    groupadd -r axway && \
    useradd -r -g axway axway

RUN yum -y update && \
    yum install --quiet -y jq  java-1.8.0-openjdk \
    yum clean all && \
    rm -rf /var/cache/yum && \
    chown -R axway:axway /opt/axway/ && \
    chmod -R 777 /opt/axway/ && \
    chmod -R 777 /tmp && \
    echo "*       hard    nproc   65535" >> /etc/security/limits.conf && \
    echo "*       soft    nproc   65535" >> /etc/security/limits.conf && \
    echo "*       hard    nofile   65535" >> /etc/security/limits.conf && \
    echo "*       soft    nofile   65535" >> /etc/security/limits.conf

RUN usermod -u 1000 axway

COPY scripts/start.sh /opt/axway/scripts/start.sh

WORKDIR /opt/axway

USER axway

CMD ["/opt/axway/scripts/start.sh"]
