#!/bin/sh

setup_vars() {
    . ./.env
}

setup_dirs() {
    mkdir -p $BINDIR
    mkdir -p $ETCDIR
    mkdir -p $PLAYDIR
}

create_image() {
    IMAGE=$DOCKER_USERNAME/$DOCKER_IMAGE:$VERSION
    if DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect $IMAGE >/dev/null; then
        docker pull $IMAGE
    else
        docker build --build-arg ANSIBLE_VERSION=$ANSIBLE_VERSION -t $DOCKER_USERNAME/$DOCKER_IMAGE .
        docker tag $DOCKER_USERNAME/$DOCKER_IMAGE purplesrl/$DOCKER_IMAGE:$VERSION
        docker tag $DOCKER_USERNAME/$DOCKER_IMAGE:$VERSION $DOCKER_USERNAME/$DOCKER_IMAGE:latest
    fi
}

setup_containit() {
    [ ! -d "$WORKDIR/containit" ] && git clone https://github.com/unboundedsystems/containit $WORKDIR/containit
    cat << EOF > $BINDIR/ansible
#!/usr/bin/env bash
IMAGE="$DOCKER_USERNAME/$DOCKER_IMAGE:$VERSION"
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
}

setup_runscript() {
    NP="PATH=\$PATH:$BINDIR"
    if ! grep -q $NP "$RC"; then
        echo $NP >> $RC
    fi
}

setup_vars
setup_dirs
create_image
setup_containit
setup_runscript
