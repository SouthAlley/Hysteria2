#!/bin/bash
###
 # @Author: Vincent Young
 # @Date: 2023-10-12 23:21:35
 # @LastEditors: Vincent Young
 # @LastEditTime: 2023-10-14 00:00:17
 # @FilePath: /Hysteria2/hy2.sh
 # @Telegram: https://t.me/missuo
 # 
 # Copyright © 2023 by Vincent, All Rights Reserved. 
### 
#!/bin/bash

show_menu() {
    echo "Hysteria 2 Installation by Vincent."
    echo "https://github.com/SouthAlley/Hysteria2"
    echo "-----------------------------------"
    echo "Choose an option:"
    echo "1. 安装 Hysteria 2"
    echo "2. 卸载 Hysteria 2"
    echo "3. 停止 Hysteria 2"
    echo "4. 开启 Hysteria 2"
    echo "5. 重启 Hysteria 2"
    echo "6. 启用开机自动启动"
    echo "7. 禁用开机自动启动"
    echo "8. 更新 Hysteria 2"
    echo "9. 退出"
    read -p "输入你的选择: " CHOICE
}

install_hysteria() {
    if netstat -tuln | grep -q ":80 "; then
        echo "Port 80 is already in use. Exiting..."
        exit 1
    fi

    # Install Hysteria 2
    bash <(curl -fsSL https://get.hy2.sh/)

    # Prompt the user for inputs with default values
    read -p "输入端口（默认：8443）: " PORT
    read -p "输入域名: " DOMAIN
    read -p "输入密码（默认：Hy2Best2024@）: " PASSWORD

    # Set default values if not provided by the user
    PORT=${PORT:-8443}
    PASSWORD=${PASSWORD:-Hy2Best2024@}

    # Create the config file
    cat << EOF > /etc/hysteria/config.yaml
listen: :$PORT

acme:
  domains:
    - $DOMAIN
  email: test@sharklasers.com

quic:
  initStreamReceiveWindow: 8388608 
  maxStreamReceiveWindow: 8388608 
  initConnReceiveWindow: 20971520 
  maxConnReceiveWindow: 20971520 
  maxIdleTimeout: 30s 
  maxIncomingStreams: 1024 
  disablePathMTUDiscovery: false

bandwidth:
  up: 200 mbps
  down: 200 mbps

ignoreClientBandwidth: false

auth:
  type: password
  password: $PASSWORD
  
masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
EOF

    echo "配置文件已创建！"
    # Start Hysteria 2
    systemctl start hysteria-server.service
    systemctl enable hysteria-server.service
    
    # Wait for 10 seconds
    sleep 10

    # Check service status
    STATUS=$(systemctl is-active hysteria-server.service)
    if [ "$STATUS" == "active" ]; then
        clear
        echo "Hysteria 2 启动成功！"
        echo "配置详细信息:"
        echo "域名: $DOMAIN"
        echo "端口: $PORT"
        echo "密码: $PASSWORD"
    else
        echo "启动 Hysteria 2 失败.请手动检查服务状态."
    fi
    echo ""
}

uninstall_hysteria() {
    bash <(curl -fsSL https://get.hy2.sh/) --remove
    rm -rf /etc/hysteria
    userdel -r hysteria
    rm -f /etc/systemd/system/multi-user.target.wants/hysteria-server.service
    rm -f /etc/systemd/system/multi-user.target.wants/hysteria-server@*.service
    systemctl daemon-reload
    echo "Hysteria 2 已卸载！"
    echo ""
}

while true; do
    show_menu

    case $CHOICE in
        1) install_hysteria ;;
        2) uninstall_hysteria ;;
        3) systemctl stop hysteria-server.service ;;
        4) systemctl start hysteria-server.service ;;
        5) systemctl restart hysteria-server.service ;;
        6) systemctl enable hysteria-server.service ;;
        7) systemctl disable hysteria-server.service ;;
        8) bash <(curl -fsSL https://get.hy2.sh/) ;;
        9) echo "Exiting..."; exit 0 ;;
        *) echo "选择无效！";;
    esac
done
