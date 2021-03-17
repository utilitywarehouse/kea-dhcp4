FROM alpine:3.13

RUN apk add --no-cache kea-dhcp4 kea-admin kea-ctrl-agent postgresql-client jq \
    && mkdir -p /run/kea

COPY scripts/start.sh /start.sh

RUN chmod +x /start.sh

ENTRYPOINT [ "/bin/sh" ]

CMD [ "-e", "/start.sh" ]
