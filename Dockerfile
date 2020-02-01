FROM alpine:3.11.3 AS builder

ARG ANSIBLE_VERSION

RUN apk --update upgrade && \
	apk add --no-cache --virtual tree bash nano python3-dev py3-pip libffi-dev openssl-dev build-base openssh-client sshpass && \
        rm -rf /var/cache/apk/* && \
        pip3 install --no-cache-dir --upgrade pip && \
		pip3 install --no-cache-dir ansible==$ANSIBLE_VERSION

FROM alpine:3.11.3 AS main

COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib

CMD ["/bin/bash"] 

