#!/bin/bash
#
# setup_postgresql.sh
#
# TODO: if you need need any security from the user database password, this
# needs work below!

if [[ $1 == "--enable-network" ]]; then ENABLE_NETWORK=true; fi

sudo sed -i '/\[base\]/a \
exclude=postgresql*' /etc/yum.repos.d/CentOS-Base.repo

sudo sed -i '/\[updates\]/a \
exclude=postgresql*' /etc/yum.repos.d/CentOS-Base.repo

curl -O http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

sudo rpm -ivh pgdg-centos93-9.3-1.noarch.rpm
sudo yum -y install postgresql93 postgresql93-server postgresql93-libs postgresql93-devel

sudo service postgresql-9.3 initdb

if [[ $ENABLE_NETWORK ]]; then
    sudo sed -i.orig \
             -e '/\(^host\W*all\W*all\W*127.0.0.1\/32\W*\)ident$/s//\1md5/' \
             -e '/\(^host\W*all\W*all\W*::1\/128\W*\)ident$/s//\1md5/' \
             /var/lib/pgsql/9.3/data/pg_hba.conf
fi

sudo chkconfig postgresql-9.3 on
sudo service postgresql-9.3 start

# Not secure
sudo su - postgres -c "psql --set ON_ERROR_STOP=1 -c \"CREATE USER $USER PASSWORD '$USER';\""
sudo su - postgres -c "psql --set ON_ERROR_STOP=1 -c \"CREATE DATABASE $USER OWNER $USER;\""


