# NFS简介
NFS(Network File System）即网络文件系统。它的主要功能是通过网络让不同主机系统之间可以共享文件或目录。   
NFS与Samba服务类似，但一般Samba服务常用于办公局域网共享，而NFS常用于互联网中小型网站集群架构后端的数据共享。    
NFS客户端将NFS服务端设置好的共享目录挂载到本地某个挂载点，对于客户端来说，共享的资源就相当于在本地的目录下。   
NFS在传输数据时使用的端口是随机选择的，依赖RPC服务来与外部通信，要想正常使用NFS,就必须保证RPC正常。    

# RPC简介   
RPC（Remote Procedure Call Protocol）远程过程调用协议。它是一种通过网络从远程计算机程序上请求服务，而不需要了解底层网络技术的协议。   
在NFS服务端和NFS客户端之间，RPC服务扮演一个中介角色，NFS客户端通过RPC服务得知NFS服务端使用的端口，从而双方可以进行数据通信。      

# 流程     
当NFS服务端启动服务时会随机取用若干端口，并主动向RPC服务注册取用相关端口及功能信息，这样，RPC服务就知道NFS每个端口对应的的NFS功能了，然后RPC服务使用固定的111端口来监听NFS客户端提交的请求，并将正确的NFS端口信息回复给请求的NFS客户端。这样，NFS客户就可以与NFS服务端进行数据传输了。

# 搭建NFS服务器端：
```
安装 nfs 与 rpc 相关软件包：
    yum install nfs-utils rpcbind -y
NFS默认的配置文件是 /etc/exports ,配置格式为：  
        NFS共享目录绝对路径    NFS客户端地址（参数）

常用参数：
    rw             read-write   读写
    ro             read-only    只读
    sync           请求或写入数据时，数据同步写入到NFS server的硬盘后才返回。数据安全，但性能降低了
    async          优先将数据保存到内存，硬盘有空档时再写入硬盘，效率更高，但可能造成数据丢失。
    root_squash    当NFS 客户端使用root 用户访问时，映射为NFS 服务端的匿名用户
    no_root_squash 当NFS 客户端使用root 用户访问时，映射为NFS 服务端的root 用户
    all_squash     不论NFS 客户端使用任何帐户，均映射为NFS 服务端的匿名用户

配置 /etc/exports：
    /sharedir 192.168.239.0/24(rw,sync,root_squash)
    
创建共享目录以及测试文件：
    mkdir -p /sharedir
    touch /sharedir/Welcom.file
    echo "Welcome to onlylink.top" >/sharedir/Welcom.file
给共享目录添加权限：
    chown -R nfsnobody.nfsnobody /sharedir/
把NFS共享目录赋予 NFS默认用户nfsnobody用户和用户组权限，如不设置，会导致NFS客户端无法在挂载好的共享目录中写入数据

启动 rpc服务并设置成开机自启动：
    /etc/init.d/rpcbind start
    chkconfig rpcbind on
启动 nfs服务并设置成开机自启动：
    /etc/init.d/nfs start
    chkconfig nfs on
```

# 客户端   

```
安装nfs 与 rpc 相关软件包：
    yum install nfs-utils rpcbind -y
启动 rpc服务并设置成开机自启动（不需要启动 NFS服务）：
    /etc/init.d/rpcbind start
    chkconfig rpcbind on

查询远程NFS 服务端中可用的共享资源：
    showmount -e 192.168.239.131
如果报如下的错误多数是防火墙导致：
    lnt_create: RPC: Port mapper failure - Unable to receive: errno 113 (No route to host)
到服务端清空 iptables默认规则 或关闭 iptables：
    iptables -F    或    service iptables stop

再次查询：
[root@test ~]# showmount -e 192.168.239.131
Export list for 192.168.239.131:
/sharedir 192.168.239.0/24

创建挂载目录，并挂载 NFS共享目录 /sharedir
    mkdir -p /sharedir
    mount -t nfs 192.168.239.131:/sharedir/ /sharedir/
如果想要开机自动将共享目录挂载到本地,往/etc/fstab 中追加：
    192.168.239.131:/sharedir/ /sharedir/ nfs defaults 0 0

验证是否有 rw 权限：
    [root@test ~]# cat /sharedir/Welcom.file 
    Welcome to onlylink.top                
    [root@test ~]# mkdir -p /sharedir/hello
    [root@test ~]# echo "Hello" >> /sharedir/Welcom.file 
    [root@test ~]# cat /share/Welcom.file
    Welcome to onlylink.top
    Hello
```

NFS服务可以让不同的客户端挂载使用同一个共享目录，将其作为共享存储使用，这样可以保证不同节点端数据一致性，在集群中经常会用到，如是Windows与Linux的混合集群,就用Samba实现。如果在大型网站可能会用到Moosefs，GlusterFS,FastDFS来代替NFS。

# 参考
1. 搭建 NFS 网络文件共享服务 . https://www.jianshu.com/p/380afd870d50