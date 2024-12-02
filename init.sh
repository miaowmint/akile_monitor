#!/bin/bash

# 下载 ak_monitor
mkdir -p /etc/ak_monitor/ && cd /etc/ak_monitor/
wget -O config.json https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/config.json
wget -O ak_monitor https://raw.githubusercontent.com/akile-network/akile_monitor/refs/heads/main/ak_monitor && chmod 755 ak_monitor
wget -O /etc/systemd/system/ak_monitor.service https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_monitor.service && chmod +x /etc/systemd/system/ak_monitor.service

# 默认值
DEFAULT_AUTH_SECRET="auth_secret"
DEFAULT_ENABLE_TG="false"
DEFAULT_TG_TOKEN="telegram_bot_token"
CONFIG_FILE="/etc/ak_monitor/config.json"

# 读取环境变量，如果没有设置，使用默认值
AUTH_SECRET="${AUTH_SECRET:-$DEFAULT_AUTH_SECRET}"
ENABLE_TG="${ENABLE_TG:-$DEFAULT_ENABLE_TG}"
TG_TOKEN="${TG_TOKEN:-$DEFAULT_TG_TOKEN}"

# 输出读取的环境变量值
echo "AUTH_SECRET: $AUTH_SECRET"
echo "ENABLE_TG: $ENABLE_TG"
echo "TG_TOKEN: $TG_TOKEN"

# 使用 sed 修改 config.json 文件中的值
sed -i "s/\"auth_secret\": \".*\"/\"auth_secret\": \"$AUTH_SECRET\"/" $CONFIG_FILE
sed -i "s/\"enable_tg\": .* /\"enable_tg\": $ENABLE_TG/" $CONFIG_FILE
sed -i "s/\"tg_token\": \".*\"/\"tg_token\": \"$TG_TOKEN\"/" $CONFIG_FILE

echo "配置文件已更新："
cat "$CONFIG_FILE"

# 启动 ak_monitor 服务
systemctl daemon-reload
systemctl enable ak_monitor
systemctl start ak_monitor

# 启动 Nginx
service nginx start

# 保持容器运行
tail -f /dev/null
