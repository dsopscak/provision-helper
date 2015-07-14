#!/bin/bash
#
# install_chef_client

VERSION=12.4.1-1
RPM=chef-${VERSION}.el6.x86_64.rpm

if [[ ! -f $RPM ]]; then
    wget https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/$RPM
fi
rpm -Uvh $RPM

