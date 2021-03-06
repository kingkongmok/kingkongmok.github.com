---
layout: post
title: "nginx"
category: linux
tags: [nginx, limit_rate, install]
---

## install

### -V 检查现有配置
可以通过`nginx -V`来检查目前的nginx设置

```bash
kk@ins14 ~ $ sudo nginx -V
nginx version: nginx/1.7.6
TLS SNI support enabled
configure arguments: --prefix=/usr --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error_log --pid-path=/run/nginx.pid --lock-path=/run/lock/nginx.lock --with-cc-opt=-I/usr/include --with-ld-opt=-L/usr/lib64 --http-log-path=/var/log/nginx/access_log --http-client-body-temp-path=//var/lib/nginx/tmp/client --http-proxy-temp-path=//var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=//var/lib/nginx/tmp/fastcgi --http-scgi-temp-path=//var/lib/nginx/tmp/scgi --http-uwsgi-temp-path=//var/lib/nginx/tmp/uwsgi --with-ipv6 --with-pcre --with-http_realip_module --with-http_ssl_module --without-mail_imap_module --without-mail_pop3_module --without-mail_smtp_module --user=nginx --group=nginx
```

* 然后照葫芦画瓢，

```bash
kk@ins14 ~ $ sudo ./configure --prefix=/usr/local/nginx-1.7.4 --user=nginx --group=nginx --without-mail_smtp_module --without-mail_pop3_module --without-mail_imap_module --with-http_ssl_module --with-http_realip_module --with-pcre --with-ipv6
```

## proxy_pass

比较好用的proxy_pass功能，注意`upstream`是写在`http` block里.

```bash
kk@ins14 ~ $ diff -u /usr/local/nginx-1.7.4/conf/nginx.conf /usr/local/nginx-1.7.4/conf/nginx.conf.default 
--- /usr/local/nginx-1.7.4/conf/nginx.conf  2014-11-04 16:42:17.000000000 +0800
+++ /usr/local/nginx-1.7.4/conf/nginx.conf.default  2014-11-04 16:43:19.730432230 +0800
@@ -13,6 +13,7 @@
     worker_connections  1024;
 }
 
+
 http {
     include       mime.types;
     default_type  application/octet-stream;
@@ -31,13 +32,6 @@
 
     #gzip  on;
 
-    upstream tomcat_upstream {
-       server 127.0.0.1:8080 ;
-       server 127.0.0.1:8081 ;
-       server 127.0.0.1:8082 ;
-       server 127.0.0.1:8083 ;
-    }
-
     server {
         listen       80;
         server_name  localhost;
@@ -46,12 +40,9 @@
 
         #access_log  logs/host.access.log  main;
 
         location / {
-            #root   html;
-            #index  index.html index.htm;
-            proxy_pass http://tomcat_upstream ;
+            root   html;
+            index  index.html index.htm;
         }
 
         #error_page  404              /404.html;
```

## limit_rate
nginx中的`limit_rate`有限制下载速度的作用，配合`if(){}`来判断爬虫bot可这样来用：

```
    if ( $http_user_agent ~ Google|Yahoo|MSN|baidu ){
        limit_rate 20k;
    }
```

### openssl and pcre

[指定openssl的路径](https://dwradcliffe.com/2013/10/04/custom-openssl-with-nginx.html)

```
./configure --prefix=/usr/local/nginx-1.7.4 --without-mail_smtp_module
--without-mail_pop3_module --without-mail_imap_module --with-http_ssl_module
--with-http_realip_module --with-openssl=/usr/local/src/openssl-1.0.2d
--with-pcre --with-pcre=/usr/local/src/pcre-8.37
```

---

## limit_req_zone

nginx 可以使用limit_req_zone模块进行限速，


创建一个zone，大小30MB，针对remote ip可做 50request/sec的限制

```
http {
...
limit_req_zone $binary_remote_addr zone=one:30m rate=50r/s;
...
```

限速中，可以使用burst作为队列长度。例如burst=10000指将10000个请求放入队列。

```
location ...
...
limit_req   zone=one  burst=10000;
```

如果加入nodelay，则将rate以外也就是50个以外的request丢弃，使用503返回。

```
location ...
...
limit_req   zone=one  burst=10000;
```

###  configure

```
configure arguments: --prefix=/usr/local/nginx-1.10.3 --without-mail_smtp_module
--without-mail_pop3_module --without-mail_imap_module --with-http_ssl_module
--with-http_realip_module --with-openssl=../openssl-1.0.2k --with-pcre
--with-pcre=../pcre-8.40 --with-zlib=../zlib-1.2.11
--with-http_stub_status_module
```

---


### [隐藏header](https://serverfault.com/questions/214242/can-i-hide-all-server-os-info)

```
# src/http/ngx_http_header_filter_module.c
static char ngx_http_server_string[] = "Server: nginx" CRLF;
static char ngx_http_server_string[] = "Server: webserver" CRLF;

# src/core/nginx.h 
#define NGINX_VER          "nginx/" NGINX_VERSION
#define NGINX_VER          "webserver/" NGINX_VERSION

#define NGINX_VERSION "1.0.4"
#define NGINX_VERSION "999"

```

```
nginx.conf
在http选项下

http{
server_tokens off;
...
}
```
