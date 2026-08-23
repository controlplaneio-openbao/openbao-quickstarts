FROM openbao/openbao:latest as openbao

USER root

RUN apk --no-cache update \
    && apk --no-cache add \
    postgresql-client \
    curl \
    jq