---
layout: post
title: "install openvpn with OpenVPN-Admin"
category: linux
tags: [vpn]
---

## [OpenVPN-Admin](https://github.com/Chocobozzz/OpenVPN-Admin)


+ 记得将**net-tools**安装上

```
yum install epel-release
yum install openvpn httpd php-mysql mariadb-server php nodejs unzip git wget sed npm net-tools vim iptables-services
npm install -g bower
systemctl enable mariadb httpd
systemctl start mariadb httpd
systemctl disable firewalld
```

运行install.sh进行安装

+ ./install.sh /var/www/html apache apache 

```
################## Server informations ##################
Server Hostname/IP: 172.26.31.201
OpenVPN protocol (tcp or udp) [tcp]: tcp
Port [443]: 443
MySQL root password: 
MySQL user name for OpenVPN-Admin (will be created): openvpn
MySQL user password for OpenVPN-Admin: 

################## Certificates informations ##################
Key size (1024, 2048 or 4096) [2048]: 
Root certificate expiration (in days) [3650]: 
Certificate expiration (in days) [3650]: 
Country Name (2 letter code) [US]: 
State or Province Name (full name) [California]: 
Locality Name (eg, city) [San Francisco]: 
Organization Name (eg, company) [Copyleft Certificate Co]: 
Organizational Unit Name (eg, section) [My Organizational Unit]: 
Email Address [me@example.net]: 
Common Name (eg, your name or your server's hostname) [ChangeMe]: 

################## Creating the certificates ##################

Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/easy-rsa/pki


Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating RSA private key, 2048 bit long modulus
..........................+++
............................................................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/pki/ca.crt


Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time

DH parameters of size 2048 created at /etc/openvpn/easy-rsa/pki/dh.pem


Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
..................................................+++
...+++
writing new private key to '/etc/openvpn/easy-rsa/pki/private/server.key.97Avi0Fldu'
-----
Using configuration from ./safessl-easyrsa.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Jan  7 03:37:53 2022 GMT (1080 days)

Write out database with 1 new entries
Data Base Updated

################## Setup OpenVPN ##################

################## Setup firewall ##################

################## Setup MySQL database ##################

################## Setup web application ##################
bower not-cached    https://github.com/twbs/bootstrap.git#^3.3.7
bower resolve       https://github.com/twbs/bootstrap.git#^3.3.7
bower not-cached    https://github.com/vitalets/x-editable.git#^1.5.1
bower resolve       https://github.com/vitalets/x-editable.git#^1.5.1
bower not-cached    https://github.com/wenzhixin/bootstrap-table.git#^1.11.0
bower resolve       https://github.com/wenzhixin/bootstrap-table.git#^1.11.0
bower not-cached    https://github.com/eternicode/bootstrap-datepicker.git#^1.6.4
bower resolve       https://github.com/eternicode/bootstrap-datepicker.git#^1.6.4
bower not-cached    https://github.com/jquery/jquery-dist.git#^2.2.4
bower resolve       https://github.com/jquery/jquery-dist.git#^2.2.4
bower download      https://github.com/vitalets/x-editable/archive/1.5.1.tar.gz
bower download      https://github.com/jquery/jquery-dist/archive/2.2.4.tar.gz
bower download      https://github.com/wenzhixin/bootstrap-table/archive/1.13.2.tar.gz
bower download      https://github.com/eternicode/bootstrap-datepicker/archive/v1.8.0.tar.gz
bower extract       jquery#^2.2.4 archive.tar.gz
bower download      https://github.com/twbs/bootstrap/archive/v3.4.0.tar.gz
bower extract       x-editable#^1.5.1 archive.tar.gz
bower resolved      https://github.com/jquery/jquery-dist.git#2.2.4
bower extract       bootstrap-datepicker#^1.6.4 archive.tar.gz
bower resolved      https://github.com/vitalets/x-editable.git#1.5.1
bower resolved      https://github.com/eternicode/bootstrap-datepicker.git#1.8.0
bower extract       bootstrap-table#^1.11.0 archive.tar.gz
bower resolved      https://github.com/wenzhixin/bootstrap-table.git#1.13.2
bower extract       bootstrap#^3.3.7 archive.tar.gz
bower resolved      https://github.com/twbs/bootstrap.git#3.4.0
bower install       jquery#2.2.4
bower install       x-editable#1.5.1
bower install       bootstrap-datepicker#1.8.0
bower install       bootstrap-table#1.13.2
bower install       bootstrap#3.4.0

jquery#2.2.4 vendor/jquery

x-editable#1.5.1 vendor/x-editable
└── jquery#2.2.4

bootstrap-datepicker#1.8.0 vendor/bootstrap-datepicker
└── jquery#2.2.4

bootstrap-table#1.13.2 vendor/bootstrap-table

bootstrap#3.4.0 vendor/bootstrap
└── jquery#2.2.4

#################################### Finish ####################################
# Congratulations, you have successfully setup OpenVPN-Admin! #
Please, finish the installation by configuring your web server (Apache, NGinx...)
and install the web application by visiting http://your-installation/index.php?installation
Then, you will be able to run OpenVPN with systemctl start openvpn@server
Please, report any issues here https://github.com/Chocobozzz/OpenVPN-Admin

################################################################################ 

```

---

### [openvpn 配置](https://openvpn.net/community-resources/how-to/)

运行网卡转发

```
sysctl -w net.ipv4.ip_forward=1
sysctl -p
```

运行地址转换
允许从vpn pools 10.8.0.0/24 到 10.255.255.0/24 进行访问。

```
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -d 10.255.255.0/24 -o enp0s8 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
```

最后生成 **/etc/openvpn/server.conf**
记得修改 **server.conf** 和 **client.ovpn** , 取消添加默认路由, 注销掉 **redirect-gateway**
添加路由可以通过server.conf进行推送，注意观察client的登陆报错

```
push "route 10.255.255.0 255.255.255.0"
push "route 10.254.254.0 255.255.255.0"
```

---

### [install php72](https://www.tecmint.com/install-php-7-in-centos-7/)

```
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install yum-utils
yum-config-manager --enable remi-php72
yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
php -v
```

修改一下时区，但不确定是否生效，之前异常主要是因为系统timezone影响mariadb

+ php.ini

```
date.timezone = PRC
```

---



