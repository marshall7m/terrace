#!/bin/bash
# shellcheck disable=SC1091

set -e

python -m venv "$VIRTUAL_ENV"
source "$VIRTUAL_ENV"/bin/activate

python3 -m pip install --upgrade pip
python3 -m pip install --upgrade pip --upgrade --no-cache-dir -r /tmp/requirements.txt

wget -q -O /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v"${TFLINT_VERSION}"/tflint_linux_amd64.zip
unzip -q /tmp/tflint.zip
mv "$(unzip -qql /tmp/tflint.zip | head -n1 | tr -s ' ' | cut -d' ' -f5-)" "$VIRTUAL_ENV"/bin/

wget -q -O "$VIRTUAL_ENV"/bin/tfsec https://github.com/tfsec/tfsec/releases/download/v"${TFSEC_VERSION}"/tfsec-linux-amd64

wget -q -O /tmp/terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v"${TFDOCS_VERSION}"/terraform-docs-v"${TFDOCS_VERSION}"-linux-amd64.tar.gz
tar -zxf /tmp/terraform-docs.tar.gz -C /tmp
mv /tmp/terraform-docs "$VIRTUAL_ENV"/bin/

wget -q -O /tmp/git-chglog.tar.gz https://github.com/git-chglog/git-chglog/releases/download/v"${GIT_CHGLOG_VERSION}"/git-chglog_"${GIT_CHGLOG_VERSION}"_linux_amd64.tar.gz
tar -zxf /tmp/git-chglog.tar.gz -C /tmp
mv /tmp/git-chglog "$VIRTUAL_ENV"/bin/

wget -q -O "$VIRTUAL_ENV"/bin/gh-md-toc https://raw.githubusercontent.com/ekalinin/github-markdown-toc/"${MARKDOWN_TOC}"/gh-md-toc

wget -q -O /tmp/semtag.tar.gz https://github.com/nico2sh/semtag/archive/refs/tags/v"${SEMTAG_VERSION}".tar.gz
tar -zxf /tmp/semtag.tar.gz -C /tmp
mv /tmp/semtag-"${SEMTAG_VERSION}"/semtag "$VIRTUAL_ENV"/bin/

wget -q -O /tmp/gh.tar.gz https://github.com/cli/cli/releases/download/v"${GH_VERSION}"/gh_"${GH_VERSION}"_linux_amd64.tar.gz
tar -zxf /tmp/gh.tar.gz -C /tmp
mv /tmp/gh_"${GH_VERSION}"_linux_amd64/bin/gh "$VIRTUAL_ENV"/bin/

wget -q -O /tmp/tfenv.tar.gz https://github.com/tfutils/tfenv/archive/refs/tags/v"${TFENV_VERSION}".tar.gz
tar -zxf /tmp/tfenv.tar.gz -C /tmp
mkdir "$VIRTUAL_ENV"/.tfenv && mv /tmp/tfenv-"${TFENV_VERSION}"/* "$VIRTUAL_ENV"/.tfenv && chmod u+x "$VIRTUAL_ENV"/.tfenv/bin/tfenv

wget -q -O - https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash -s -- -b "$VIRTUAL_ENV"/bin -d "${TGSWITCH_VERSION}"
chmod u+x "$VIRTUAL_ENV"/bin/*