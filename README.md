正在大改脚本，请不要使用！

安装主控端（前后端打包到一起了）

```
bash <(curl -sL https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/akile_monitor.sh)            
```
```
curl -sSL -O https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/akile_monitor.sh && chmod +x akile_monitor.sh && bash akile_monitor.sh
```

然后根据脚本最后的提示在需要被监控的机器上安装监控端

```
bash <(curl -sL https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_client.sh)          
```
```
curl -sSL -O https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_client.sh && chmod +x ak_client.sh && bash ak_client.sh
```
