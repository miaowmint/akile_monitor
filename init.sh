    #!/bin/bash

    # 下载 ak_monitor
    mkdir -p /etc/ak_monitor/ && cd /etc/ak_monitor/
    wget -O config.json https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/config.json
    wget -O ak_monitor https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/ak_monitor && chmod 777 ak_monitor
    wget -O /etc/supervisor/conf.d/ak_monitor.conf https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_monitor.conf

    # 默认值
    DEFAULT_AUTH_SECRET="auth_secret"
    DEFAULT_ENABLE_TG="false"
    DEFAULT_TG_TOKEN="telegram_bot_token"
    DEFAULT_ENABLE_WSS="false"
    DEFAULT_SOCKET="localhost"
    CONFIG_FILE="/etc/ak_monitor/config.json"

    # 读取环境变量，如果没有设置，使用默认值
    AUTH_SECRET="${AUTH_SECRET:-$DEFAULT_AUTH_SECRET}"
    ENABLE_TG="${ENABLE_TG:-$DEFAULT_ENABLE_TG}"
    TG_TOKEN="${TG_TOKEN:-$DEFAULT_TG_TOKEN}"
    ENABLE_WSS="${ENABLE_WSS:-$DEFAULT_ENABLE_WSS}"
    SOCKET="${SOCKET:-$DEFAULT_SOCKET}"

    # 输出读取的环境变量值
    echo "AUTH_SECRET: $AUTH_SECRET"
    echo "ENABLE_TG: $ENABLE_TG"
    echo "TG_TOKEN: $TG_TOKEN"
    echo "ENABLE_WSS: $ENABLE_WSS"
    echo "SOCKET: $SOCKET"

    # 使用 sed 修改 config.json 文件中的值
    sed -i "s/\"auth_secret\": \".*\"/\"auth_secret\": \"$AUTH_SECRET\"/" $CONFIG_FILE
    sed -i "s/\"enable_tg\": .* /\"enable_tg\": $ENABLE_TG/" $CONFIG_FILE
    sed -i "s/\"tg_token\": \".*\"/\"tg_token\": \"$TG_TOKEN\"/" $CONFIG_FILE

    echo "配置文件已更新："
    cat "$CONFIG_FILE"

    # 构建前端文件
    git clone https://github.com/akile-network/akile_monitor_fe.git && cd akile_monitor_fe
    npm install
    if [ "$ENABLE_WSS" = "true" ]; then
        sed -i "s|socket: 'ws://localhost/ws'|socket: 'wss://$SOCKET/ws'|" ./src/config/index.js
    else
        sed -i "s|socket: 'ws://localhost/ws'|socket: 'ws://$SOCKET/ws'|" ./src/config/index.js
    fi
    npm run build
    cp -rf ./dist/* /usr/share/nginx/html/ && cd ../ && rm -rf akile_monitor_fe

    # 启动 Nginx
    service nginx start

    # 启动 ak_monitor 服务
    service supervisor start
    supervisorctl start ak_monitor
    supervisorctl status ak_monitor

    # 保持容器运行
    tail -f /dev/null
