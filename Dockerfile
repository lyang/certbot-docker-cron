FROM docker.io/certbot/dns-cloudflare:latest

RUN apk upgrade --no-cache && \
    apk add --no-cache bash curl jq && \
    rm -rf /tmp/* /var/cache/apk/* /var/tmp/*

COPY . /etc/certbot

ENV CERTBOT_CONFIG="/etc/certbot/config.json"

ENTRYPOINT ["/etc/certbot/entrypoint.sh"]

CMD ["crond", "-f", "-d", "6"]
