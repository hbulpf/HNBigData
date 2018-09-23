#!/bin/bash
#安装 nfs 软件包
yum install nfs-utils -y

showmount -e 139.199.196.253   #查询远程NFS 服务端中可用的共享资源
mkdir -p /crawler_pic   #创建挂载目录，并挂载 NFS共享目录 /sharedir
mount -t nfs 139.199.196.253:/home/ftpuser/www /crawler_pic
echo "139.199.196.253:/home/ftpuser/www /crawler_pic nfs defaults 0 0" >>/etc/fstab #开机自动将共享目录挂载到本地

#测试          
mkdir -p /crawler_pic/hello
cd /crawler_pic/hello
touch hello.txt
echo "Hello" >> hello.txt
cat hello.txt