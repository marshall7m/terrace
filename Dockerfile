FROM python:3.9-slim-buster AS build

ARG TERRAFORM_VERSION=0.14.4
ARG TERRAGRUNT_VERSION=0.27.1
ARG TFLINT_VERSION=0.23.0
ARG TFSEC_VERSION=0.36.11
ARG TFDOCS_VERSION=0.10.1

ENV PIP_PACKAGES="tftest pre-commit pytest cached-property terraenv boto3"
ENV BUILD_PACKAGES="wget unzip"
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY install.sh /tmp/install.sh

RUN python3 -m venv $VIRTUAL_ENV \
    && chmod u+x /tmp/install.sh \
    && /tmp/install.sh

FROM python:3.9-slim-buster

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /opt/venv /opt/venv

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PATH="$VIRTUAL_ENV/lib/python3.9/site-packages:$PATH"

ENV RUNTIME_PACKAGES="bash git"
ENV HOME /opt/terrace
WORKDIR $HOME

RUN apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_PACKAGES \
    && git config --global advice.detachedHead false

COPY /scripts /scripts

ENTRYPOINT [ "/bin/bash", "/scripts/entrypoint.sh" ]
CMD ["--help"]