#!/bin/bash

#  _ __ ___ (_) __ _  _____      ___ __ ___ (_)_ __ | |_ 
# | '_ ` _ \| |/ _` |/ _ \ \ /\ / / '_ ` _ \| | '_ \| __|
# | | | | | | | (_| | (_) \ V  V /| | | | | | | | | | |_ 
# |_| |_| |_|_|\__,_|\___/ \_/\_/ |_| |_| |_|_|_| |_|\__|

Green="\033[32m"
Font="\033[0m"
Red="\033[31m"

install_docker(){
    if [[ $(curl -s "https://www.loliapi.com/getip/?type=country") == "CN" ]]; then
        echo -e "${Green}检测到服务器位于中国大陆，开始测速并使用docker境内安装源${Font}"
        sources=(
            "https://mirrors.aliyun.com/docker-ce"
            "https://mirrors.tencent.com/docker-ce"
            "https://mirrors.163.com/docker-ce"
            "https://mirrors.cernet.edu.cn/docker-ce"
        )
        get_average_delay() {
            local source=$1
            local total_delay=0
            local iterations=3
            for ((i = 0; i < iterations; i++)); do
                delay=$(curl -o /dev/null -s -w "%{time_total}\n" "$source")
                total_delay=$(awk "BEGIN {print $total_delay + $delay}")
            done
            average_delay=$(awk "BEGIN {print $total_delay / $iterations}")
            echo "$average_delay"
        }
        min_delay=${#sources[@]}
        selected_source=""
        for source in "${sources[@]}"; do
            average_delay=$(get_average_delay "$source")
            if (( $(awk 'BEGIN { print '"$average_delay"' < '"$min_delay"' }') )); then
                min_delay=$average_delay
                selected_source=$source
            fi
        done
        if [ -n "$selected_source" ]; then
            echo -e "${Green}选择延迟最低的源 $selected_source ，延迟为 $min_delay 秒${Font}"
            export DOWNLOAD_URL="$selected_source"
        else
            echo -e "${Red}无法选择境内安装源，使用默认官方源${Font}"
        fi
    else
        echo -e "${Red}服务器位于非中国大陆地区，继续${Font}"   
    fi
    sleep 1s
    curl -fsSL https://get.docker.minq.cn | bash -s docker
    configure_docker
}

configure_docker(){
    rm -f /etc/docker/daemon.json
    if [[ $(curl -s "https://www.loliapi.com/getip/?type=country") == "CN" ]]; then
    echo "服务器位于中国，添加加速镜像源"
    curl -sSLk https://www.minq.cn/dockerdaemoncn.json -o /etc/docker/daemon.json
    else
    echo "服务器不位于中国，使用默认配置文件"
    curl -sSLk https://www.minq.cn/dockerdaemon.json -o /etc/docker/daemon.json
    fi
    systemctl daemon-reload
    systemctl restart docker
    echo -e "${Green}docker配置完成${Font}"
    sleep 1s
    cat /etc/docker/daemon.json
}

# 随机生成 auth_secret
generate_random_secret() {
  tr -dc 'A-Za-z0-9_-' </dev/urandom | head -c 16
}

# 获取服务器 IP
get_server_ip() {
  wget -qO- https://4.ipw.cn/
}

# 询问配置项
echo -e "${Green}请输入通信密钥 auth_secret 并牢记（直接回车将随机生成一个）：${Font}"
read auth_secret

if [ -z "$auth_secret" ]; then
  auth_secret=$(generate_random_secret)
  echo -e "${Green}已随机生成 auth_secret: ${Red}$auth_secret${Font}"
fi

echo -e "${Green}请输入web网页端口（默认 8080）：${Font}"
read web_port
web_port=${web_port:-"8080"}

echo -e "${Green}请输入ws监听端口（默认 :3000）：${Font}"
read listen
listen=${listen:-"3000"}

echo -e "${Green}是否启用 Telegram通知（默认 false，输入 true 启用）: ${Font}"
read enable_tg
enable_tg=${enable_tg:-"false"}

if [ "$enable_tg" == "true" ]; then
  echo -e "${Green}请输入 tg_bot_token: ${Font}"
  read tg_token
else
  tg_token=""
fi

# 获取服务器的外网 IP 地址
server_ip=$(get_server_ip)
if [ -z "$server_ip" ]; then
  echo -e "${Red}无法获取服务器 IP，继续执行脚本...${Font}"
  server_ip="你的服务器IP"
fi

echo -e "${Green}请输入后端WebSocket地址(格式如 12.13.14.15:3000 ，回车默认使用 ${Font}服务器IP:ws监听端口 ${Green}$server_ip:$listen): ${Font}"
read ws_address
ws_address=${ws_address:-"$server_ip:$listen"}

# Docker，启动！
docker_cmd="docker run -d -p $listen:3000 -p $web_port:80 \
    -e AUTH_SECRET=\"$auth_secret\" \
    -e ENABLE_TG=$enable_tg \
    -e TG_TOKEN=\"$tg_token\" \
    -e SOCKET=\"$ws_address\" \
    -v /etc/ak_monitor:/etc/ak_monitor \
    -v /etc/ak_monitor/index:/usr/share/nginx/html \
    my-static-site"

if command -v docker &> /dev/null; then
    echo "Docker 已安装，继续执行脚本..."
else
    echo "Docker 未安装，安装 Docker"
    install_docker
fi

echo -e "${Green}正在启动 Docker 容器...${Font}"
echo -e "${Green}执行命令: $docker_cmd${Font}"

# 执行 Docker 启动命令
eval $docker_cmd

# 提示信息
echo -e "${Green}主控端已启动！web页面访问地址为：${Font} http://$server_ip:$web_port"
echo -e "${Green}请在需要监控的服务器运行以下命令安装 agent：${Font}"
echo -e "${Red}bash <(curl -sL https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_client.sh)${Font}"
echo -e "${Green}其中通信密钥 auth_secret 为：${Red}$auth_secret${Font}"
echo -e "${Green}其中主控端 url 为：${Red}http://$server_ip:$listen${Font}"
