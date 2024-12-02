FROM nginx:alpine

EXPOSE 80

RUN apk add --no-cache bash wget unzip jq openrc

RUN mkdir -p /usr/share/nginx/html && \
    wget -O /tmp/akile_monitor_fe.zip https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/akile_monitor_fe.zip && \
    unzip /tmp/akile_monitor_fe.zip -d /usr/share/nginx/html && \
    rm /tmp/akile_monitor_fe.zip
    
RUN wget -O /init.sh https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/init.sh && \  
    chmod +x /init.sh

CMD ["/init.sh"]
