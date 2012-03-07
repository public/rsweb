#!/bin/sh

set -e
set -x


PREFIX=$(readlink -f build-env)
OPENSSL_VERSION="0.9.8r"

test -d $PREFIX || mkdir -v $PREFIX

git submodule init
git submodule sync
git submodule update

# these are both fairly normal autotools projects
cd boost.m4
./bootstrap
./configure --prefix="$PREFIX"
make
make install

cd ../jansson
autoreconf -fvi
./configure --prefix="$PREFIX"
make
make install

# purely JS stuff, just needs to exist in the right place so the rsjs 
# symlink has something to point at
cd ../
hg clone https://code.google.com/p/pagedown/ || (cd pagedown && hg pull && hg update && cd ../)

# not a normal autotools project, but does support make install, and --prefix etc.
wget -O/dev/stdout https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz | tar -zxv
cd openssl-$OPENSSL_VERSION
./config --prefix="$PREFIX" threads shared zlib-dynamic
make
make test
make install

