FROM python:3.9-slim-buster AS build

ARG TERRAFORM_VERSION=0.14.4
ARG TERRAGRUNT_VERSION=0.27.1
ARG TFLINT_VERSION=0.23.0
ARG TFSEC_VERSION=0.36.11
ARG TFDOCS_VERSION=0.10.1

COPY install.sh /tmp/install.sh

ENV BUILD_PACKAGES="wget unzip"
RUN chmod u+x /tmp/install.sh \
    && /tmp/install.sh

FROM alpine:3.13.0

COPY --from=build /usr/local/bin /usr/local/bin
ENV RUNTIME_PACKAGES="bash git"
ENV HOME /opt/terrace
WORKDIR $HOME
COPY ./scripts ./scripts

RUN apk add --no-cache $RUNTIME_PACKAGES \
    && git config --global advice.detachedHead false \
    && mkdir -p $HOME

ENTRYPOINT [ "/bin/bash", "./scripts/args.sh" ]