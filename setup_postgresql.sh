#!/bin/bash
#
# setup_postgresql.sh
#
# synopsis:
#
#   setup_postgresql.sh [--enable-network [<class C ipv4 address]]
#
#     If --enable-network is supplied, enables localhost (loop-back)
#     interface. If, additionaly, a class C ipv address is supplied,
#     enables service on that address to other hosts on same network.
#     Only meaningful if that is indeed the address assigned to the
#     host.
# 
#
# TODO: if you need need any security from the user database password, this
# needs work below!

if [[ -z $DBUSER ]]; then DBUSER=$USER; fi

if [[ $1 == "--enable-network" ]]; then
    ENABLE_NETWORK=true
    IP=$2 
    if [[ $IP ]]; then
        # convert, for example, 192.168.33.99 to 192.168.33.0/24
        MASKED=$(echo $IP | sed '/\([1-9][0-9]\{0,2\}\.[1-9][0-9]\{0,2\}\.[1-9][0-9]\{0,2\}\)\.[1-9][0-9]\{0,2\}/s//\1.0\/24/')
    fi
fi

sudo sed -i '/\[base\]/a \
exclude=postgresql*' /etc/yum.repos.d/CentOS-Base.repo

sudo sed -i '/\[updates\]/a \
exclude=postgresql*' /etc/yum.repos.d/CentOS-Base.repo

wget https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-redhat10-10-2.noarch.rpm

sudo rpm -ivh pgdg-redhat10-10-2.noarch.rpm
sudo yum -y install postgresql10 postgresql10-server postgresql10-libs postgresql10-devel

# Adapted from the old 9.3 init.d script's initdb function
PGDATA=/var/lib/pgsql/10/data
PGLOG=/var/lib/pgsql/10/pgstartup.log
PGENGINE=/usr/pgsql-10/bin
sudo mkdir -p "$PGDATA"
sudo chown postgres:postgres "$PGDATA"
sudo chmod go-rwx "$PGDATA"
sudo /sbin/restorecon "$PGDATA"
sudo touch "$PGLOG"
sudo chown postgres:postgres "$PGLOG"
sudo chmod go-rwx "$PGLOG"
sudo /sbin/restorecon "$PGLOG"
sudo /sbin/runuser -l postgres -c "$PGENGINE/initdb --pgdata='$PGDATA' --auth='ident' >>\"$PGLOG\" 2>&1"
sudo mkdir "$PGDATA/pg_log"
sudo chown postgres:postgres "$PGDATA/pg_log"
sudo chmod go-rwx "$PGDATA/pg_log"


if [[ $ENABLE_NETWORK ]]; then
    sudo sed -i.orig \
        -e '/\(^host\W*all\W*all\W*127.0.0.1\/32\W*\)ident$/s//\1md5/' \
        -e '/\(^host\W*all\W*all\W*::1\/128\W*\)ident$/s//\1md5/' \
        $PGDATA/pg_hba.conf

    if [[ $IP ]]; then
        sudo sed -i.orig \
            -e "/^#listen_addresses = .*$/s//listen_addresses = 'localhost,$IP'/" \
            -e "/^#port = 5432.*$/s//port = 5432/" \
            $PGDATA/postgresql.conf
        echo "host    all             all             $MASKED        md5" \
            | sudo tee -a $PGDATA/pg_hba.conf
    fi
fi

sudo systemctl enable postgresql-10
sudo systemctl start postgresql-10

# Not secure
sudo su - postgres -c "psql --set ON_ERROR_STOP=1 -c \"CREATE USER $DBUSER PASSWORD '$DBUSER';\""
sudo su - postgres -c "psql --set ON_ERROR_STOP=1 -c \"CREATE DATABASE $DBUSER OWNER $DBUSER;\""


