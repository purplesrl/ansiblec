FROM alpine:3.11.3 AS builder

ARG ANSIBLE_VERSION

RUN apk --update upgrade && \
	apk add --no-cache python3-dev py3-pip libffi-dev openssl-dev build-base openssh-client sshpass && \
        pip3 install --no-cache-dir --upgrade pip && \
		pip3 install --no-cache-dir ansible==$ANSIBLE_VERSION && \
		apk del py3-pip python3-dev libffi-dev openssl-dev build-base && \
		rm -rf /var/cache/apk/*

FROM alpine:3.11.3 AS main

COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib

CMD ["/bin/sh"] 

