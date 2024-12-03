脚本方案为：主控前端 in docker；主控后端安装在主机；监控端也是安装在主机

因为我只用debian，所以不知道其它系统能不能用

```
curl -sSL -O https://raw.githubusercontent.com/miaowmint/akile_monitor/refs/heads/main/ak_install.sh && chmod +x ak_install.sh && bash ak_install.sh
```
