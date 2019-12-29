FROM alpine:latest

RUN apk --update upgrade && \
	apk add tree bash nano ansible openssh-client && \
	rm -rf /var/cache/apk/*

CMD ["/bin/bash"] 

