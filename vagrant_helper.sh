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

make_builduser()
{
    local the_user=$1

    # Add the user to the vagrant group which should make
    # vagrant-mounted shares writable for him. Assuming staging areas
    # will be in such shares, allows build user to stage stuff.
    sudo sed -e "s/^vagrant:.*$/&$the_user/" -i.orig /etc/group
}
