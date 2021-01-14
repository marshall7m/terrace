FROM python:3.9-slim-buster

RUN apt-get update \
    && apt-get install -y --no-install-recommends git wget bash unzip apt-utils \
    && git config --global advice.detachedHead false \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* \
    && pip install pre-commit pytest terraenv

ARG TERRAFORM_VERSION=0.14.4
ARG TERRAGRUNT_VERSION=0.27.1
ARG TFLINT_VERSION=0.23.0
ARG TFSEC_VERSION=0.36.11
ARG TFDOCS_VERSION=0.10.1

RUN wget -q -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip -q /tmp/terraform.zip \
    && mv $(unzip -qql /tmp/terraform.zip | head -n1 | tr -s ' ' | cut -d' ' -f5-) /usr/local/bin/ \
    && wget -q -O /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
    && wget -q -O /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip -q /tmp/tflint.zip \
    && mv $(unzip -qql /tmp/tflint.zip | head -n1 | tr -s ' ' | cut -d' ' -f5-) /usr/local/bin/ \
    && wget -q -O /usr/local/bin/tfsec https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 \
    && wget -q -O /usr/local/bin/terraform-docs https://github.com/terraform-docs/terraform-docs/releases/download/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-linux-amd64 \
    && chmod u+x /usr/local/bin/*

ENV HOME /opt/terrace
RUN mkdir -p $HOME
WORKDIR $HOME

COPY ./scripts/ /scripts/
ENTRYPOINT [ "/bin/bash", "/scripts/entrypoint.sh" ]