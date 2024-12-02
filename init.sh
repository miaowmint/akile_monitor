#!/bin/bash

# 下载 ak_monitor
mkdir -p /etc/ak_monitor/ && cd /etc/ak_monitor/
wget -O config.json https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/config.json
wget -O ak_monitor https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/ak_monitor && chmod 755 ak_monitor
wget -O /etc/init.d/ak_monitor https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_monitor.rc && chmod +x /etc/init.d/ak_monitor

# 启动 OpenRC
openrc
touch /run/openrc/softlevel
rc-update add ak_monitor default

# 配置文件路径
CONFIG_FILE="/etc/ak_monitor/config.json"

# 读取环境变量并更新配置
AUTH_SECRET=${AUTH_SECRET:-"default_auth_secret"}
ENABLE_TG=${ENABLE_TG:-false}
TG_TOKEN=${TG_TOKEN:-"default_telegram_bot_token"}

# 更新配置文件中的字段
if [ -f "$CONFIG_FILE" ]; then
    jq --arg auth_secret "$AUTH_SECRET" \
       --argjson enable_tg "$ENABLE_TG" \
       --arg tg_token "$TG_TOKEN" \
       '.auth_secret = $auth_secret | .enable_tg = $enable_tg | .tg_token = $tg_token' \
       "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
else
    echo "配置文件不存在：$CONFIG_FILE"
    exit 1
fi

echo "配置文件已更新："
cat "$CONFIG_FILE"

# 启动 ak_monitor 服务
rc-service ak_monitor start

# 启动 Nginx
nginx -g "daemon off;"
