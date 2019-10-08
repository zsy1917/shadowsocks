#!/bin/bash
# -*- coding:utf-8 -*-
#shell for centos7

read -p "Port : " port
read -p "Password : " password

yum install -y python-setuptools && easy_install pip
pip install shadowsocks

#创建 ss 服务, 随系统启动
cat << EOF >/usr/lib/systemd/system/shadowsocks.service
[Unit]
Description=Shadowsocks Server
Documentation=https://github.com/shadowsocks/shadowsocks
After=network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
ExecStart=/usr/bin/ssserver -c /etc/shadowsocks.json -d start
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/usr/bin/ssserver -c /etc/shadowsocks.json -d stop
[Install]
WantedBy=multi-user.target
EOF

#创建 ss 配置文件
cat << EOF >/etc/shadowsocks.json
{
"server":"::",
"server_port":${port},
"local_address":"127.0.0.1",
"local_port":1080,
"password":"${password}",
"timeout":300,
"method":"aes-256-cfb",
"fast_open": false
}
EOF

#启动ss服务
systemctl enable shadowsocks
systemctl start shadowsocks

#添加规则确保 SS 所使用的端口能正常使用
firewall-cmd --zone=public --add-port=${port}/tcp --permanent
firewall-cmd --zone=public --add-port=${port}/udp --permanent
firewall-cmd --complete-reload







