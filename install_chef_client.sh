#!/bin/bash
#
# install_chef_client

VERSION=16.7.61-1
RPM=chef-${VERSION}.el7.x86_64.rpm

if [[ ! -f $RPM ]]; then
    wget https://packages.chef.io/files/stable/chef/16.7.61/el/8/$RPM
fi
sudo yum localinstall $RPM

