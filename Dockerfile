FROM centos:7.6.1810 as builder

RUN echo "Adding username [axway] to the system." && \
    groupadd -r axway && \
    useradd -r -g axway axway && \
    mkdir -p /opt/axway/FlowManager/runtime && \
    mkdir -p /opt/axway/FlowManager/logs && \
    mkdir -p /opt/axway/FlowManager/conf/license && \
    mkdir -p /opt/axway/configs && \
    mkdir -p /opt/axway/FlowManager/resources && \
    mkdir -p /opt/axway/FlowManager/conf/schemas/storage/ && \
    mkdir -p /opt/axway/FlowManager/data/keys/com.axway.nodes.ume && \
    mkdir -p /home/axway && \
    chown -R axway:axway /home/axway && \
    chmod -R 777 /home/axway && \
    chmod -R 777 /opt/axway

# install FC OS prerequisites
RUN yum install --quiet -y wget unzip

ARG URL="<ARTIFACT_LOCATION>"

# SNAPSHOT VERSION OR RELEASE NUMBER
ARG RELEASE_TYPE="<RELEASE_TYPE>/"

# FC ARTIFACT
ARG ARTIFACT="<ARTIFACT>"

RUN wget -nc -r --accept "*zip" --level 1 -nH --cut-dirs=100 "$URL$RELEASE_TYPE$ARTIFACT" -P /home/axway/KIT && \
    unzip /home/axway/KIT/$ARTIFACT -d /opt/axway/FlowManager/ 

COPY ./bin/uid_entrypoint /opt/axway/bin/uid_entrypoint

FROM alpine:3.9

ENV JAVA_ALPINE_VERSION=8.242.08-r0 \
    JAVA_VERSION=8u242C 

RUN apk add -q shadow && \
    groupadd axway && \
    adduser -D -u 1001 -h /opt/axway -g '' -G axway axway && \
    apk --update --no-cache add openjdk8=8.242.08-r0 && \ 
    apk upgrade --no-cache && \
    apk del shadow 

COPY --from=builder  --chown=axway:axway /opt/axway/ /opt/axway/

RUN chmod -R u+x /opt/axway && \
    chgrp -R 0 /opt/axway && \
    chmod -R g=u /opt/axway /etc/passwd && \
    rm -rf /var/cache/apk/* /usr/bin/nc /usr/bin/wget /usr/bin/vi /usr/bin/passwd /usr/bin/nslookup /usr/bin/hexdump /sbin/ip* /sbin/if* /sbin/lsmod /sbin/modprobe /sbin/arp /sbin/route /sbin/apk /sbin/insmod /bin/chmod /bin/chown /bin/ed && \
    ulimit -S -p 5000

USER 1001

COPY ./resources/conf_to_import.txt /opt/axway/FlowManager/conf.properties

ENTRYPOINT [ "/opt/axway/bin/uid_entrypoint" ]

WORKDIR /opt/axway/FlowManager

HEALTHCHECK --interval=1m \
            --timeout=5s \
            --start-period=1m \
            --retries=3 \
            CMD java -jar opcmd.jar status
