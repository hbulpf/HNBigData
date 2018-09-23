#!/bin/bash

yum -y install vsftpd   #conf目录/etc/vsftpd/vsftpd.conf 

useradd ftpuser
passwd ftpuser  #设置密码为: hnbdchen

#开启 21端口
# vim /etc/sysconfig/iptables
# service iptables restart 

#修改 selinux配置
getsebool -a | grep ftp
setsebool -P allow_ftpd_full_access on
setsebool -P ftp_home_dir on

sed -i 's/^anonymous_enable=.*/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf
sed -i '$a\pasv_min_port=30000' /etc/vsftpd/vsftpd.conf
sed -i '$a\pasv_max_port=30999' /etc/vsftpd/vsftpd.conf

# chkconfig vsftpd on  #设置开机启动
systemctl start vsftpd
systemctl enable vsftpd


#https://blog.csdn.net/csdn_lqr/article/details/53333946