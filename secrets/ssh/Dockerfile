FROM openbao/openbao:latest as openbao

USER root

RUN apk --no-cache update \
    && apk --no-cache add \
    openssh-client

RUN mkdir /root/.ssh
COPY known_hosts /root/.ssh/known_hosts
RUN chmod 700 /root/.ssh && \
    chmod 644 /root/.ssh/known_hosts