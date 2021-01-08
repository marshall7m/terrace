FROM alpine:3.12.3
RUN mkdir -p /opt/local/bin
ENV HOME /opt/local
ENV PATH="${HOME}/bin:$PATH"
RUN apk add --update --no-cache git openssh bash curl sudo
RUN git config --global advice.detachedHead false
RUN sudo chmod u+x /opt/local/bin && cd /opt/local
RUN mkdir -p .tfenv
RUN git clone --depth 1 --branch v2.0.0 https://github.com/tfutils/tfenv.git  ${HOME}/.tfenv
ENV PATH="${HOME}/.tfenv/bin:$PATH"
# install terraform check packages
ARG TF_FLINT_VERSION=v0.23.0
RUN curl -s -L https://github.com/terraform-linters/tflint/releases/download/${TF_FLINT_VERSION}/tflint_linux_amd64.zip > ${HOME}/bin/tflint
ARG TF_SEC_VERSION=v0.36.11
RUN curl -L -s https://github.com/tfsec/tfsec/releases/download/${TF_SEC_VERSION}/tfsec-linux-amd64 > ${HOME}/bin/tfsec