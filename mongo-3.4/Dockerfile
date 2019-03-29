FROM mongo:3.4

ENV AUTH yes
ENV STORAGE_ENGINE wiredTiger
ENV JOURNALING yes
COPY run.sh /run.sh
COPY set_mongodb_password.sh /set_mongodb_password.sh
RUN usermod -u 1000 mongodb
USER mongodb
CMD ["/run.sh"]
