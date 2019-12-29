FROM alpine:latest

RUN apk --update upgrade && \
	apk add nano ansible openssh-client && \
	rm -rf /var/cache/apk/*

CMD ["/usr/bin/ansible"]

