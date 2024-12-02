#!/bin/bash

#  _ __ ___ (_) __ _  _____      ___ __ ___ (_)_ __ | |_ 
# | '_ ` _ \| |/ _` |/ _ \ \ /\ / / '_ ` _ \| | '_ \| __|
# | | | | | | | (_| | (_) \ V  V /| | | | | | | | | | |_ 
# |_| |_| |_|_|\__,_|\___/ \_/\_/ |_| |_| |_|_|_| |_|\__|

Green="\033[32m"
Font="\033[0m"
Red="\033[31m"

default_auth_secret="default_auth_secret"
default_url="http://defaulturl.com:3000"
default_net_name="eth0"
default_name="HK-Akile"

configure_akile_monitor_client(){

    echo -e "${Green}请输入通信密钥 auth_secret ，与主控端设置的通信密钥相同: ${Font}"
    read auth_secret
    if [ -z "$auth_secret" ]; then
        auth_secret=$default_auth_secret
    fi
    echo -e "${Green}请输入主控端url (例如：http://yourdomain.com:3000) : ${Font}"
    read url
    if [ -z "$url" ]; then
        url=$default_url
    fi
    echo -e "${Green}请输入监控的网卡名 net_name (例如：eth0，默认值：$default_net_name) ${Red}如果不懂请不要修改此项，直接回车！！！: ${Font}"
    read net_name
    if [ -z "$net_name" ]; then
        net_name=$default_net_name
    fi

    echo -e "${Green}请输入节点名称 (例如：HK-Akile) : ${Font}"
    read name
    if [ -z "$name" ]; then
        name=$default_name
    fi

    install_akile_monitor_client
}
# 安装akile_monitor
install_akile_monitor_client(){
    mkdir -p /etc/ak_monitor/ && cd /etc/ak_monitor/

    # 下载并设置ak_client
    wget -O client https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/client/client && chmod 777 client

    # 下载client.json文件模板
    wget -O client.json https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/client/client.json

    # 修改client.json文件中的内容
    sed -i "s/\"auth_secret\": \"auth_secret\"/\"auth_secret\": \"$auth_secret\"/" client.json
    sed -i "s#\"url\": \"http://yourdomain.com:3000\"#\"url\": \"$url\"#" client.json
    sed -i "s/\"net_name\": \"eth0\"/\"net_name\": \"$net_name\"/" client.json
    sed -i "s/\"name\": \"HK-Akile\"/\"name\": \"$name\"/" client.json

    # ak_client.service
    cat > /etc/systemd/system/ak_client.service <<EOF
[Unit]
Description=AkileCloud Monitor Service
After=network.target nss-lookup.target
Wants=network.target

[Service]
User=root
Group=root
Type=simple
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=999999999
WorkingDirectory=/etc/ak_monitor/
ExecStart=/etc/ak_monitor/client
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF

    # 启用服务，使其开机自启动
    systemctl daemon-reload
    systemctl start ak_client
    systemctl enable ak_client
    
    cat /etc/ak_monitor/client.json
}

configure_akile_monitor_client
