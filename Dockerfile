FROM python:3.9 AS build
ARG TFLINT_VERSION=0.23.0
ARG TFSEC_VERSION=0.36.11
ARG TFDOCS_VERSION=0.16.0
ARG GIT_CHGLOG_VERSION=0.14.2
ARG SEMTAG_VERSION=0.1.1
ARG GH_VERSION=2.2.0
ARG TFENV_VERSION=2.2.2
# defaults to installing latest
ARG TGSWITCH_VERSION=""

SHELL ["/bin/bash", "-c"]
WORKDIR /src

ENV VIRTUAL_ENV=/opt/base-venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY install.sh /tmp/install.sh
COPY requirements.txt /tmp/requirements.txt

RUN chmod u+x /tmp/install.sh \
    && bash /tmp/install.sh

FROM python:3.9-slim-buster
ARG TERRAFORM_VERSION=latest
ARG TERRAGRUNT_VERSION=latest

WORKDIR /src/

ENV VIRTUAL_ENV=/opt/base-venv
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PATH="$VIRTUAL_ENV/.tfenv/bin:$PATH"
# places virtual env in front of system-wide packages
ENV PATH="$VIRTUAL_ENV/bin:$VIRTUAL_ENV/lib/python3.9/site-packages:$PATH"

COPY --from=build $VIRTUAL_ENV $VIRTUAL_ENV

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends git nodejs lbzip2 jq \
    && ln -sf python3 /usr/local/bin/python \
    && git config --global advice.detachedHead false \
    && tfenv install "${TERRAFORM_VERSION}" \
    && tfenv use "${TERRAFORM_VERSION}" \
    && if [[ "$TERRAGRUNT_VERSION" == "latest" ]]; then \
        curl -s https://warrensbox.github.io/terragunt-versions-list/ | jq -r '.Versions[0]' | xargs -I {} tgswitch {}; \
    else tgswitch "$TERRAGRUNT_VERSION"; fi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT ["bash", "/tmp/entrypoint.sh"]