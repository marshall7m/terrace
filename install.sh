#!/bin/bash
apt-get -y update
apt-get install -y aptitude
aptitude install -y software-properties-common build-essential wget unzip git

python -m venv $VIRTUAL_ENV
source $VIRTUAL_ENV/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade pip --upgrade --no-cache-dir -r /tmp/requirements.txt

wget -q -O /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip
unzip -q /tmp/tflint.zip
mv $(unzip -qql /tmp/tflint.zip | head -n1 | tr -s ' ' | cut -d' ' -f5-) /usr/local/bin/

wget -q -O /usr/local/bin/tfsec https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64
wget -q -O /usr/local/bin/terraform-docs https://github.com/terraform-docs/terraform-docs/releases/download/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-linux-amd64

wget -q -O /tmp/git-chglog.tar.gz https://github.com/git-chglog/git-chglog/releases/download/v${GIT_CHGLOG_VERSION}/git-chglog_${GIT_CHGLOG_VERSION}_linux_amd64.tar.gz
tar -zxf /tmp/git-chglog.tar.gz -C /tmp
mv /tmp/git-chglog /usr/local/bin/

wget -q -O /tmp/semtag.tar.gz https://github.com/nico2sh/semtag/archive/refs/tags/v${SEMTAG_VERSION}.tar.gz
tar -zxf /tmp/semtag.tar.gz -C /tmp
mv /tmp/semtag-${SEMTAG_VERSION}/semtag /usr/local/bin/

wget -q -O /tmp/gh.tar.gz https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz
tar -zxf /tmp/gh.tar.gz -C /tmp
mv /tmp/gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/

wget -q -O /tmp/tfenv.tar.gz https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.tar.gz
tar -zxf /tmp/tfenv.tar.gz -C /tmp
mkdir /usr/local/.tfenv && mv /tmp/tfenv-${TFENV_VERSION}/* /usr/local/.tfenv && chmod u+x /usr/local/.tfenv/bin/tfenv

wget -q -O - https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash -s -- -b /usr/local/bin -d "${TGSWITCH_VERSION}"

chmod u+x /usr/local/bin/*
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*