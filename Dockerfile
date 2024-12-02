FROM nginx:alpine

EXPOSE 80

RUN apk add --no-cache bash wget unzip jq openrc

RUN mkdir -p /usr/share/nginx/html && \
    wget -O /tmp/akile_monitor_fe.zip https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/akile_monitor_fe.zip && \
    unzip /tmp/akile_monitor_fe.zip -d /usr/share/nginx/html && \
    rm /tmp/akile_monitor_fe.zip

RUN mkdir -p /etc/ak_monitor/ && \
    cd /etc/ak_monitor/ && \
    wget -O config.json https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/config.json && \
    wget -O ak_monitor https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/ak_monitor && \
    chmod 755 ak_monitor

RUN wget -O /etc/init.d/ak_monitor https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_monitor.rc && \
    chmod +x /etc/init.d/ak_monitor

RUN rc-update add ak_monitor default

RUN wget -O /init.sh https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/init.sh && \
    chmod +x /init.sh

CMD ["/init.sh"]
