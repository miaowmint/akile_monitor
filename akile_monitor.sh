#!/bin/bash

#  _ __ ___ (_) __ _  _____      ___ __ ___ (_)_ __ | |_ 
# | '_ ` _ \| |/ _` |/ _ \ \ /\ / / '_ ` _ \| | '_ \| __|
# | | | | | | | (_| | (_) \ V  V /| | | | | | | | | | |_ 
# |_| |_| |_|_|\__,_|\___/ \_/\_/ |_| |_| |_|_|_| |_|\__|

Green="\033[32m"
Font="\033[0m"
Red="\033[31m"

select_download_file(){
    os=$(uname -s)
    arch=$(uname -m)
    
    if [[ "$os" == "Linux" ]]; then
        if [[ "$arch" == "x86_64" ]]; then
            file="akile_monitor-linux-amd64"
        elif [[ "$arch" == "aarch64" ]]; then
            file="akile_monitor-linux-arm64"
        else
            echo -e "${Red}似乎是不支持的架构: $arch on $os ${Font}"
            exit 1
        fi
    elif [[ "$os" == "Darwin" ]]; then
        if [[ "$arch" == "x86_64" ]]; then
            file="akile_monitor-darwin-amd64"
        elif [[ "$arch" == "aarch64" ]]; then
            file="akile_monitor-darwin-arm64"
        else
            echo -e "${Red}似乎是不支持的架构: $arch on $os ${Font}"
            exit 1
        fi
    else
        echo -e "${Red}似乎是不支持的系统？: $os${Font}"
        exit 1
    fi
}

generate_random_secret() {
  tr -dc 'A-Za-z0-9_-' </dev/urandom | head -c 16
}

configure_akile_monitor(){

    echo -e "${Green}请输入通信密钥 auth_secret 并牢记（直接回车将随机生成一个）：${Font}"
    read auth_secret
    if [ -z "$auth_secret" ]; then
    auth_secret=$(generate_random_secret)
    echo -e "${Green}已随机生成 auth_secret: ${Red}$auth_secret${Font}"
    fi

    echo -e "${Green}请输入ws监听端口（默认 :3000）：${Font}"
    read listen
    listen=${listen:-"3000"}

    echo -e "${Green}是否启用 Telegram 通知（默认 false，输入 true 启用）: ${Font}"
    read enable_tg
    enable_tg=${enable_tg:-"false"}

    if [ "$enable_tg" == "true" ]; then
    echo -e "${Green}请输入你的 telegram_bot_token : ${Font}"
    read tg_token
    else
    tg_token="your_telegram_bot_token"
    fi

    echo -e "${Green}请输入 update_uri （监控端与主控端通信用的uri，默认 /monitor）：${Font}"
    read update_uri
    update_uri=${update_uri:-"/monitor"}

    echo -e "${Green}请输入 web_uri （你查看网页面板的时候与主控端通信用的uri，默认 /ws）：${Font}"
    read web_uri
    web_uri=${web_uri:-"/ws"}

    echo -e "${Green}请输入 hook_uri （AkileMonitorBot与主控端通信用的uri，默认 /hook）：${Font}"
    read hook_uri
    hook_uri=${hook_uri:-"/hook"}

    echo -e "${Green}请输入 hook_token （hook通信使用的token，默认 hook_token）：${Font}"
    read hook_token
    hook_token=${hook_token:-"hook_token"}

    install_akile_monitor
}
# 安装akile_monitor
install_akile_monitor(){
    select_download_file

    # 下载ak_monitor
    mkdir -p /etc/ak_monitor/ && cd /etc/ak_monitor/
    echo -e "${Green}开始下载 $file${Font}"
    wget -O ak_monitor https://github.com/akile-network/akile_monitor/releases/download/v0.01/$file && chmod 777 ak_monitor

    # config.json
    cat > /etc/ak_monitor/config.json << EOF
{
  "auth_secret": "${auth_secret}",
  "listen": ":${listen}",
  "enable_tg": ${enable_tg},
  "tg_token": "${tg_token}",
  "hook_uri": "${hook_uri}",
  "update_uri": "${update_uri}",
  "web_uri": "${web_uri}",
  "hook_token": "${hook_token}"
}
EOF

    cat /etc/ak_monitor/config.json

    # ak_monitor.service
    cat > /etc/systemd/system/ak_monitor.service <<EOF
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
ExecStart=/etc/ak_monitor/ak_monitor
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF

    # 启用服务，使其开机自启动
    systemctl daemon-reload
    systemctl start ak_monitor
    systemctl enable ak_monitor
}

configure_akile_monitor
