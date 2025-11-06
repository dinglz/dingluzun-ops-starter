***zabbix安装方式：***

- zabbix服务端编译安装
- zabbix客户端yum安装

***部署zabbix服务端流程  ***

1. ✅ 部署ngx+php环境并测试  
2. ✅ 部署数据库 mariadb 10.5及以上 然后进行配置  
3. ✅ 编译安装zabbix-server服务端及后续配置  
4. ✅ 部署前端代码代码进行访问  
5. web访问  
6. 配置客户端

  

***1.部署nginx+php 环境并测试***

```YAML
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

```

```Bash
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

yum install epel-release.noarch -y 

curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum install php72w-cli php72w-fpm php72w-gd php72w-mbstring php72w-bcmath php72w-xml php72w-ldap php72w-mysqlnd -y

```

```Bash
[root@zabbix-server ~]# rpm -qa | egrep 'php|nginx'
php72w-mysqlnd-7.2.34-1.w7.x86_64
php72w-ldap-7.2.34-1.w7.x86_64
php72w-gd-7.2.34-1.w7.x86_64
php72w-fpm-7.2.34-1.w7.x86_64
php72w-bcmath-7.2.34-1.w7.x86_64
php72w-mbstring-7.2.34-1.w7.x86_64
nginx-1.26.1-2.el7.ngx.x86_64
php72w-common-7.2.34-1.w7.x86_64
php72w-pdo-7.2.34-1.w7.x86_64  
php72w-cli-7.2.34-1.w7.x86_64
php72w-xml-7.2.34-1.w7.x86_64
[root@zabbix-server ~]# rpm -qa | egrep 'php|nginx' | wc -l
11
```

```nginx
server {
 listen 80;
 server_name admin.zabbix.cn;
 root /app/code/zbx;
 location / {
   index index.php;
 }
 location ~ \.php$ {
   fastcgi_pass  127.0.0.1:9000;
   fastcgi_index index.php;
   fastcgi_param SCRIPT_FILENAME  
   $document_root$fastcgi_script_name;
   include fastcgi_params;
 }
}
```

```Bash
1. 进行替换
sed -ri  '/^(user|group)/s#apache#nginx#g' /etc/phpfpm.d/www.conf
2. 进行检查
egrep '^(user|group)' /etc/php-fpm.d/www.conf
user = nginx
group = nginx
```

***2.部署数据库***

- zabbix 6.0 不支持Mariadb5.5 安装mariadb 10.6
- 配置Mariadb yum源

```Ini
[mariadb]
name=MariaDB
baseurl=https://mirrors.aliyun.com/mariadb/yum/10.6/centos7-amd64/
gpgkey=https://mirrors.aliyun.com/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
enabled=1
```

```Bash
yum install -y mariadb-server 
rpm -qa |grep -i mariadb

#启动
systemctl enable mariadb
systemctl  start mariadb

```

```SQL
  
  mysql_secure_installation
  #如果是mariadb 10.5以上使用一下命令
  mariadb-secure-installation
Enter current password for root (enter for none):
回车
 Switch to unix_socket authentication [Y/n] 输入n
 Change the root password? [Y/n] 输入n 不设置root密码
 Remove anonymous users? [Y/n]   输入Y
 Disallow root login remotely? [Y/n] 输入Y
 Remove test database and access to it? [Y/n] 输入Y
 Reload privilege tables now? [Y/n] 输入Y
 Thanks for using MariaDB! 表示完成

```

```Markdown
#1. 创建数据库要指定字符集
create database zabbix charset utf8   collate utf8_bin;
#2. 创建zabbix用户
grant all on zabbix.* to 'zabbix'@'localhost'
identified by 'zabbix' ;
# 如果数据库与zbx,php不在一起
#grant all on zabbix.* to 'zabbix'@'172.16.1.%' identified by 'zabbix' ; 
# sql文件在源代码中.
tar xf zabbix-6.0.14.tar.gz
cd zabbix-6.0.14/database/mysql/
mysql zabbix <schema.sql
mysql zabbix <images.sql
mysql zabbix <data.sql
mysql zabbix <double.sql
mysql zabbix <history_pk_prepare.sql

```

***3.编译安装zabbix-server***

- ✅ 准备编译安装zabbix-server  
- ✅ 修改zbx服务端配置文件  
- ✅ 启动zbx服务端  
- ✅书写systemctl配置文件

```Bash
#安装依赖
yum install -y mysql-devel pcre-devel openssl-devel zlib-devel libxml2-devel net-snmp-devel   net-snmp libssh2-devel OpenIPMI-devel libevent-devel openldap-devel   libcurl-devel
#配置
./configure  --sysconfdir=/etc/zabbix/ --enable-server --with-mysql --with-net-snmp  --with-libxml2  --with-ssh2  --with-openipmi   --with-zlib --with-libpthread   --with-libevent      --with-openssl  --with-ldap  --with-libcurl  --with-libpcre
make install

#启动zabbix-server
useradd -s /sbin/nologin -M zabbix 
zabbix-server

#如果提示
zabbix_server [84067]: cannot open "/var/log/zabbix_server.log": [13] Permission denied
#说明此路径权限不足为他提权
chmod 755 /var/log/zabbix_server.log
chown  zabbix.zabbix /var/log/zabbix_server.log
```

```Ini
#书写systemctl文件
cat /etc/systemd/system/zabbix-server.service
[Unit]
Description=Zabbix Server with MySQL DB
After=syslog.target network.target
[Service]
Type=simple
ExecStart=/usr/local/sbin/zabbix_server -f
User=zabbix
[Install]
WantedBy=multi-user.target

#加载配置文件
systemctl daemon-reload
#关闭手动启动的zabbix-server
pkill zabbix-server

# 检查是否关闭成功
ps -ef |grep zabbix
# 启动与检查
systemctl enable zabbix-server
systemctl start zabbix-server
systemctl status zabbix-server



```

**4.*****部署前端代码代码进行访问***

```Bash
cp -r zabbix-6.0.5/ui/* /app/code/zbx/
chown -R nginx.nginx /app/code/zbx/
#访问域名或IP

```



***5.安装客户端***

```Bash
1.配置zabbix源
rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/6.0/rhel/7/x86_64/zabbix-release-latest.el7.noarch.rpm
sed -i 's#https://repo.zabbix.com/zabbix/#https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/#g' /etc/yum.repos.d/zabbix.repo
2.安装客户端
**yum install -y zabbix-agent2**
```
