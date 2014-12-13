#!/bin/bash
#
# vagrant_helper.sh
#
# Vagrant versions of provisioner helper functions

set_nameserver()
{
    local ip=$1

    sudo sed -e "s/^nameserver\s.*/nameserver $ip/" \
             -e "/^search\s.*$/d" \
             -i.orig /etc/resolv.conf
    
    # insure the eth0 interface's dhcp doesn't overwrite above
    # nameserver setting.
    echo "PEERDNS=no" | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth0
}
