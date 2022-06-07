FROM python:3.9-slim-buster AS build
ARG TFLINT_VERSION=0.23.0
ARG TFSEC_VERSION=0.36.11
ARG TFDOCS_VERSION=0.10.1
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
    && sh /tmp/install.sh

FROM python:3.9-slim-buster
ARG TERRAFORM_VERSION=latest
ARG TERRAGRUNT_VERSION=latest

# sets default shell to /bin/bash so `source` cmd is available
SHELL ["/bin/bash", "-c"]
WORKDIR /src/

ENV VIRTUAL_ENV=/opt/base-venv
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PATH="/usr/local/.tfenv/bin:$PATH"
# uses virtual env instead of system-wide packages
ENV PATH="$VIRTUAL_ENV/bin:$VIRTUAL_ENV/lib/python3.9/site-packages:$PATH"

COPY --from=build /usr/local /usr/local
COPY --from=build $VIRTUAL_ENV $VIRTUAL_ENV

RUN apt-get -y update \
    && apt-get install -y nodejs lbzip2 \
    && apt-get install -y --no-install-recommends bash git curl unzip jq \
    && ln -sf python3 /usr/local/bin/python \
    && git config --global advice.detachedHead false \
    && tfenv install ${TERRAFORM_VERSION} \
    && tfenv use ${TERRAFORM_VERSION} \
    && tgswitch ${TERRAGRUNT_VERSION}

COPY entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT ["bash", "/tmp/entrypoint.sh"]