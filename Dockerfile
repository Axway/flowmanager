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
    chmod -R 777 /opt/axway


# install FC OS prerequisites
RUN yum install --quiet -y wget unzip

ARG FC_URL="http://repository4.ecd.axway.int/content/repositories/cg-snapshot/com/axway/flowcentral/delivery/flowcentral-delivery-light-distrib/"
# SNAPSHOT VERSION OR RELEASE NUMBER
ARG FC_RELEASE_TYPE="<fc_release_type>"
# FC ARTIFACT
ARG FC_ARTIFACT="<fc_artifact>"

RUN wget -nc -r --accept "*zip" --level 1 -nH --cut-dirs=100 "$FC_URL$FC_RELEASE_TYPE$FC_ARTIFACT" -P /home/axway/FC_KIT && \
    unzip /home/axway/FC_KIT/$FC_ARTIFACT -d /opt/axway/FlowCentral/ 
    


FROM openjdk:8u201-jdk-alpine

RUN apk add -q shadow && \
    groupadd axway && \
    adduser -D -u 1000 -h /opt/axway -g '' -G axway axway && \
    echo "*       hard    nproc   65535" >> /etc/security/limits.conf && \
    echo "*       soft    nproc   65535" >> /etc/security/limits.conf && \
    echo "*       hard    nofile   65535" >> /etc/security/limits.conf && \
    echo "*       soft    nofile   65535" >> /etc/security/limits.conf
 
COPY --from=builder  --chown=axway:axway /opt/axway/ /opt/axway/

USER axway 

COPY ./resources/conf_to_import.txt /opt/axway/FlowCentral/conf.properties
COPY ./scripts/start.sh /opt/axway/scripts/start.sh

WORKDIR /opt/axway/FlowCentral


CMD ["/opt/axway/scripts/start.sh"]
