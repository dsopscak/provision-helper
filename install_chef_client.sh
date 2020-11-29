#!/bin/bash
#
# install_chef_client

VERSION=16.7.61
RPM=chef-${VERSION}-1.el7.x86_64.rpm

mkdir -p ~/.chef/accepted_licenses
tee ~/.chef/accepted_licenses/chef_infra_client <<EOT
---
id: infra-client
name: Chef Infra Client
date_accepted: '2020-11-29T16:48:07+00:00'
accepting_product: infra-client
accepting_product_version: $VERSION
user: vagrant
file_format: 1
EOT

tee ~/.chef/accepted_licenses/inspec <<EOT
---
id: inspec
name: Chef InSpec
date_accepted: '2020-11-29T16:48:07+00:00'
accepting_product: infra-client
accepting_product_version: $VERSION
user: vagrant
file_format: 1
EOT

if [[ ! -f $RPM ]]; then
    wget --progress=bar:force https://packages.chef.io/files/stable/chef/16.7.61/el/8/$RPM
fi
sudo yum localinstall -y $RPM

