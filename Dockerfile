FROM python:3.8-alpine

RUN set -eux; \
    apk add --no-cache \
        git \
        gpg \
        alpine-sdk \
        bash \
        libffi-dev \
    ;
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
