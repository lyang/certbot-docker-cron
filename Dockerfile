FROM docker.io/certbot/dns-cloudflare:latest

RUN apk upgrade --no-cache && \
    apk add --no-cache bash && \
    rm -rf /tmp/* /var/cache/apk/* /var/tmp/*

COPY certbot.sh /etc/periodic/daily

COPY deploy-hook.sh /usr/local/bin

COPY entrypoint.sh /usr/local/bin

VOLUME ["/opt/cloudflare"]

ENTRYPOINT ["entrypoint.sh"]

CMD ["crond", "-f", "-d", "6"]
