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

RUN wget -nc -r --accept "*zip" --level 1 -nH --cut-dirs=100 "$FC_URL$FC_RELEASE_TYPE$FC_ARTIFACT" -P /home/axway/FC_KIT && \
    unzip /home/axway/FC_KIT/$FC_ARTIFACT -d /opt/axway/FlowCentral/
    


FROM centos:7.6.1810

RUN echo "Adding username [axway] to the system." && \
    groupadd -r axway && \
    useradd -r -g axway axway
    
COPY --from=builder  --chown=axway:axway /opt/axway/FlowCentral /opt/axway/FlowCentral

RUN usermod -u 1000 axway

COPY resources/conf_to_import.txt /opt/axway/resources/conf_to_import.txt
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

WORKDIR /opt/axway

USER axway

CMD ["/opt/axway/scripts/start.sh"]
