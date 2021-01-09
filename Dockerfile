FROM alpine:3.12.3

RUN apk add -q --no-cache --virtual .build_deps sudo wget py-pip \
    && apk add -q --no-cache git openssh bash \
    && git config --global advice.detachedHead false \
    && pip install --ignore-installed pre-commit \
    && apk del .build_deps

ARG TFENV_VERSION=v2.0.0
ARG TFLINT_VERSION=v0.23.0
ARG TFSEC_VERSION=v0.36.11
ARG TFDOCS_VERSION=v0.10.1
RUN wget -q -O /tmp/tfenv.zip https://github.com/tfutils/tfenv/archive/${TFENV_VERSION}.zip \
    && unzip -q /tmp/tfenv \
    && mv $(unzip -qql /tmp/tfenv.zip | head -n1 | tr -s ' ' | cut -d' ' -f5-) /usr/local/bin/.tfenv \
    && wget -q -O /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip -q /tmp/tflint.zip \
    && mv $(unzip -qql /tmp/tflint.zip | head -n1 | tr -s ' ' | cut -d' ' -f5-) /usr/local/bin/ \
    && chmod u+x /usr/local/bin/tflint \
    && wget -q -O /usr/local/bin/tfsec https://github.com/tfsec/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 \
    && chmod u+x /usr/local/bin/tfsec \
    && wget -q -O /usr/local/bin/tfdocs https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/terraform-docs-${TFDOCS_VERSION}-linux-amd64 \
    chmod u+x /usr/local/bin/tfdocs

ENV PATH "/usr/local/bin/.tfenv/bin:$PATH"
RUN rm /tmp/*
ENV HOME /opt/terrace
RUN mkdir -p $HOME
WORKDIR $HOME

COPY ./scripts/entrypoint.sh /scripts/entrypoint.sh
ENTRYPOINT [ "/bin/sh", "/scripts/entrypoint.sh" ]
CMD [ "/bin/sh" ]