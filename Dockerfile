FROM python:3.11-alpine

RUN set -eux; \
    apk add --no-cache \
        git \
        gpg \
        bash \
    ;
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
