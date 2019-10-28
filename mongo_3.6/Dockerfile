FROM mongo:3.6.12

ENV AUTH yes
ENV STORAGE_ENGINE wiredTiger
ENV JOURNALING yes
COPY scripts/run.sh /run.sh
COPY scripts/set_mongodb_password.sh /set_mongodb_password.sh
USER mongodb
CMD ["/run.sh"]
