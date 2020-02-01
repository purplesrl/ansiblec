#!/bin/bash

# Setting up vars

VERSION=1.0.3
ANSIBLE_VERSION=2.8.5
KEY=$HOME/.ssh/id_rsa
RC=$HOME/.bashrc
WORKDIR=$HOME/.ansible
BINDIR=$WORKDIR/bin
ETCDIR=$WORKDIR/etc
PLAYDIR=$WORKDIR/play
IMAGE=ansible-alpine

# Creating dirs

mkdir -p $BINDIR
mkdir -p $ETCDIR
mkdir -p $PLAYDIR

# Building docker image

docker build --build-arg ANSIBLE_VERSION=$ANSIBLE_VERSION -t inductance/$IMAGE .
docker tag inductance/$IMAGE inductance/$IMAGE:$VERSION
docker tag inductance/$IMAGE:$VERSION inductance/$IMAGE:latest

# Setting up containit

[ ! -d "$WORKDIR/containit" ] && git clone https://github.com/unboundedsystems/containit $WORKDIR/containit

# Generating runscript

cat << EOF > $BINDIR/ansible
#!/usr/bin/env bash
IMAGE="inductance/$IMAGE"
DOCKER_ARGS="-v $KEY:/root/.ssh/id_rsa:ro -v $ETCDIR:/etc/ansible:ro -v \$SSH_AUTH_SOCK:/ssh-agent:ro -e SSH_AUTH_SOCK=/ssh-agent"
BIN_DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"
WORKDIR=\${BIN_DIR/\/bin}
PWD=\`pwd\`
if [[ \$PWD != \$WORKDIR* ]]; then
	echo -e "\e[31mError: You need to run the command from \$WORKDIR or a subdirectory\e[0m"
	exit 0
fi
. "\${BIN_DIR}/../containit/containit.sh"
EOF

chmod +x $BINDIR/ansible

[ ! -f "$BINDIR/ansible-playbook" ] && ln -s $BINDIR/ansible $BINDIR/ansible-playbook

# Adding path to runscript

NP="PATH=\$PATH:$BINDIR"

if ! grep -q $NP "$RC"; then
   echo $NP >> $RC
fi

