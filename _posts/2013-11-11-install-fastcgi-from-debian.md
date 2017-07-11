---
layout: post
title: "install fastcgi from debian"
category: linux
tags: [debian insstall fastcgi]
---

```
sudo apt-get install nginx fcgiwrap spawn-fcgi
```

是使用nginx+fastcgi来实现的，和php5-fpm稍稍有点不一样的是，linux本身能解析perl，所以不需要另外安装php解析软件，只需要一个fcgiwrap就可以了，启动的就是它了。fcgiwrap是作为一个socket监听的，所以在nginx中需要指定相应socket。
下面是在/etc/init.d/fcgiwrap的描述

```
kk@debian:/etc/init.d$ cat fcgiwrap  | grep socket -C 3
 
# FCGI_APP Variables
FCGI_CHILDREN="1"
FCGI_SOCKET="/var/run/$NAME.socket"
FCGI_USER="www-data"
FCGI_GROUP="www-data"
# Socket owner/group (will default to FCGI_USER/FCGI_GROUP if not defined)
```

所以，如果要简单运行，只需修改一下nginx的socket就能解析语言了可以了。在location / 后加一个 关于pl的block。
fcgiwrap不必修改。

```
kk@debian:/etc/nginx/sites-available$ diff default default.orig 
24,25c24
<   #root /usr/share/nginx/www;
<   root /home/kk/public_html;
---
>   root /usr/share/nginx/www;
27d25
<   autoindex on ;
30c28
<   server_name _;
---
>   server_name localhost;
39,46d36
< 
<       location ~ \.pl$ {
<         gzip off;
<         include /etc/nginx/fastcgi_params;
<         fastcgi_pass unix:/var/run/fcgiwrap.socket;
<         fastcgi_index index.pl;
<         #fastcgi_param SCRIPT_FILENAME /home/kk/public_html/$fastcgi_script_name ;
<     }
 
 
kk@debian:~$ perl -ne 'print unless /^(\s+)?(#|$)/' /etc/nginx/sites-available/default 
server {
    root /home/kk/public_html;
    index index.html index.htm;
    autoindex on ;
    server_name _;
    location / {
        try_files $uri $uri/ /index.html;
    }
        location ~ \.pl$ {
        gzip off;
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/fcgiwrap.socket;
        fastcgi_index index.pl;
    }
    location /doc/ {
        alias /usr/share/doc/;
        autoindex on;
        allow 127.0.0.1;
        allow ::1;
        deny all;
    }
}
```
