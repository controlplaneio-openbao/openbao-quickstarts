FROM openbao/openbao:latest as openbao

USER root

RUN apk --no-cache update \
    && apk --no-cache add \
    xdg-utils \
    curl \
    w3m \
    jq