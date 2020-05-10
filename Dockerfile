FROM alpine:3.11.3 AS builder

ARG ANSIBLE_VERSION

# Build

RUN apk --update upgrade && \
    apk add --no-cache python3-dev py3-pip libffi-dev openssl-dev build-base openssh-client sshpass && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir paramiko pywinrm ansible==$ANSIBLE_VERSION

# Cleanup

RUN apk del py3-pip python3-dev libffi-dev openssl-dev build-base && \
    apk add --no-cache python3 && \
    rm -rf /var/cache/apk/*

# Generate image

FROM alpine:3.11.3 AS main

COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib

CMD ["/bin/sh"] 

