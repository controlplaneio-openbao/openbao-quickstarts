FROM openbao/openbao:latest AS openbao

USER root

RUN apk --no-cache update \
    && apk --no-cache add \
    jq \
    openldap-clients

USER openbao