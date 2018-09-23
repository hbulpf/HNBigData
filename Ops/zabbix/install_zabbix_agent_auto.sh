#!/bin/bash
#suto install zabbix_agentd
#author :swh
echo  "Now  this shell will install zabbix_agentd autoly:please wait"
yum install net-snmp-devel libxml2-devel libcurl-devel  -y
echo "add zabbix group and user:"
groupadd zabbix
useradd   -r zabbix  -g  zabbix  -s /sbin/nologin
echo "download package -make and make install "
cd  /usr/local/src
wget -c  "http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.4.2/zabbix-3.4.2.tar.gz"
tar -xzvf zabbix-3.4.2.tar.gz
cd zabbix-3.4.2
./configure --prefix=/usr/local/zabbix-3.4.2/ --enable-agent
make
make install
ret=$?     
if [ $? -eq 0 ]
  then     
        read  -p "please input zabbix_serverIP:"  zabbix_serverIP
        sed -i 's/Server=127.0.0.1/Server='$zabbix_serverIP'/' /usr/local/zabbix-3.4.2/etc/zabbix_agentd.conf
        sed -i 's/ServerActive=127.0.0.1/ServerActive='$zabbix_serverIP'/' /usr/local/zabbix-3.4.2/etc/zabbix_agentd.conf
        sed -i 's/Hostname=Zabbix server/Hostname='$HOSTNAME'/' /usr/local/zabbix-3.4.2/etc/zabbix_agentd.conf
        echo "zabbix install success,you need set hostname: $HOSTNAME"
         
else
        echo "install failed,please check"
fi 
/usr/local/zabbix-3.4.2/sbin/zabbix_agentd
if [ $? -eq 0 ]
  then
        echo "set zabbix_agentd start with system"
        echo "/usr/local/zabbix-3.4.2/sbin/zabbix_agentd start" >> /etc/rc.d/rc.local
else
        echo "start error,please check"
fi