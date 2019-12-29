#!/bin/bash

# Setting up vars

VERSION=1.0.0
KEY=$HOME/.ssh/id_rsa
RC=$HOME/.bashrc
WORKDIR=$HOME/.ansible
BINDIR=$WORKDIR/bin
ETCDIR=$WORKDIR/etc
IMAGE=ansible-alpine

# Creating dirs

mkdir -p $BINDIR
mkdir -p $ETCDIR

# Building docker image

docker build -t inductance/$IMAGE .
docker tag inductance/$IMAGE inductance/$IMAGE:$VERSION
docker tag inductance/$IMAGE:$VERSION inductance/$IMAGE:latest

# Setting up containit

[ ! -d "$WORKDIR/containit" ] && git clone https://github.com/unboundedsystems/containit $WORKDIR/containit

# Generating runscript

cat << EOF > $BINDIR/ansible
#!/usr/bin/env bash
IMAGE="inductance/$IMAGE"
DOCKER_ARGS="-v $KEY:/root/.ssh/id_rsa:ro -v $ETCDIR:/etc/ansible:ro -v \$SSH_AUTH_SOCK:/ssh-agent:ro -e SSH_AUTH_SOCK=/ssh-agent"
BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${BINDIR}/../containit/containit.sh"
EOF

chmod +x $BINDIR/ansible

# Adding path to runscript

NP="PATH=\$PATH:$BINDIR"

if ! grep -q $NP "$RC"; then
   echo $NP >> $RC
fi

