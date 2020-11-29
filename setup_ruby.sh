#!/bin/env bash
#
# setup_ruby.sh

sudo dnf install -y git curl \
    bison gcc make bzip2 openssl-devel libyaml libffi-devel \
    readline-devel zlib-devel gdbm-devel ncurses-devel

curl -sL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash -

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc



