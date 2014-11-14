---
layout: post
title: "keepalive analyze"
category: linux
tags: [keepalive, nginx, tomcat]
---
{% include JB/setup %}

## 架构
目前使用的架构是tomcat-tomcat{0,1,2,3}，研究一下nginx和upstreams之间的keepalive。以下配置为测试机上的设置

### nginx setting
根据[这里](http://www.cnblogs.com/echovalley/archive/2013/04/02/2994634.html)的介绍来设置nginx部分
解析也可以看看[这里](http://bert82503.iteye.com/blog/2152613)

```
http {
    ...

    ##
    # 与Client连接的长连接配置
    ##
    # http://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_requests
    # 设置通过"一个存活长连接"送达的最大请求数（默认是100，建议根据客户端在"keepalive"存活时间内的总请求数来设置）
    # 当送达的请求数超过该值后，该连接就会被关闭。（通过设置为5，验证确实是这样）
    keepalive_requests 8192;
 
    # http://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout
    # 第一个参数设置"keep-alive客户端长连接"将在"服务器端"继续打开的超时时间（默认是75秒，建议根据具体业务要求来，但必须要求所有客户端连接的"Keep-Alive"头信息与该值设置的相同(这里是5分钟)，同时与上游服务器(Tomcat)的设置是一样的）
    # 可选的第二个参数设置“Keep-Alive: timeout=time”响应头字段的值
    keepalive_timeout 300s 300s;
 
    ...
    include /etc/nginx/web_servers.conf;
    include /etc/nginx/proxy_params;
}

web_servers.conf：
upstream web_server {
    server 127.0.0.1:8080;

    # http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive
    # 连接到上游服务器的最大并发空闲keepalive长连接数（默认是未设置，建议与Tomcat Connector中的maxKeepAliveRequests值一样）
    # 当这个数被超过时，使用"最近最少使用算法(LUR)"来淘汰并关闭连接。
    keepalive 512;
}

server {
    listen 80;
    server_name lihg.com www.lihg.com;
 
    location / {
        proxy_pass http://web_server;
 
        ##
        # 与上游服务器(Tomcat)建立keepalive长连接的配置，可参考上面的keepalive链接里的"For HTTP"部分
        ##
        # http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_http_version
        # 设置代理的HTTP协议版本（默认是1.0版本）
        # 使用keepalive连接的话，建议使用1.1版本。
        proxy_http_version 1.1;
        # http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_set_header
        # 允许重新定义或追加字段到传递给代理服务器的请求头信息（默认是close）
        proxy_set_header Connection "";
 
        proxy_redirect off;
    }
}
```

### tomcat setting

可以继续根据[这里](http://bert82503.iteye.com/blog/2152613)来设置,这里是其中一个tomcat的配置

```
 <!-- 
        maxThreads：由此连接器创建的最大请求处理线程数，这决定可同时处理的最大并发请求数（默认为200）
        minSpareThreads：保持运行状态的最小线程数（默认为10）
        acceptCount：接收传入的连接请求的最大队列长度（默认队列长度为100）
    
        connectionTimeout：在接收一条连接之后，连接器将会等待请求URI行的毫秒数（默认为60000，60秒）
        maxConnections：在任何给定的时间，服务器能接收和处理的最大连接数（NIO的默认值为10000）
        keepAliveTimeout：在关闭这条连接之前，连接器将等待另一个HTTP请求的毫秒数（默认使用connectionTimeout属性值）
        maxKeepAliveRequests：在该连接被服务器关闭之前，可被流水线化的最大HTTP请求数（默认为100）
    
        enableLookups：启用DNS查询（默认是DNS查询被禁用）
        compression：连接器是否启用HTTP/1.1 GZIP压缩，为了节省服务器带宽
        compressionMinSize：指定输出响应数据的最小大小（默认为2048，2KB）
        compressableMimeType：可使用HTTP压缩的文件类型
        server：覆盖HTTP响应的Server头信息
     --> 
    <Connector port="8081" protocol="HTTP/1.1"
               maxThreads="512"
               minSpareThreads="10"
               acceptCount="768"

               connectionTimeout="1000"
               maxConnections="1280"
               keepAliveTimeout="300000"
               maxKeepAliveRequests="512"

               redirectPort="8443" />
```

```
$ diff -u backup_files/server.xml server.xml
--- backup_files/server.xml 2014-10-17 23:04:54.000000000 +0800
+++ server.xml 2014-11-12 16:52:54.000000000 +0800
@@ -70,7 +70,7 @@
     -->
     <Connector port="7711" protocol="HTTP/1.1" 
                 acceptCount="6000" executor="tomcatThreadPool"
-                connectionTimeout="20000" disableUploadTimeout="true" maxKeepAliveRequests="256"  keepAliveTimeout="120000"
+                connectionTimeout="20000" disableUploadTimeout="true" 
                 URIEncoding="UTF-8" enableLookups="false"
                 redirectPort="8443" server="t-http"/>
     <!-- A "Connector" using the shared thread pool-->
```

### testing
使用httperf和tcpdump来观察情况,如果F比较少证明keepalive运行成功。

```
$ httperf --hog --server=localhost --num-conns=100000 &

$ sudo nice /usr/sbin/tcpdump -n -i lo tcp port 8081 or port 8082 or port 8083 -c 1000 | perl -nae '$h{$F[6]}++ if $F[6]=~/F/}{printf "%s %s\n\n",$h{$_},$_ for keys%h'
error : ret -1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 262144 bytes
1000 packets captured
2128 packets received by filter
0 packets dropped by kernel
2 [F.],
```


使用[tcpdump](http://danielmiessler.com/study/tcpdump/)来检查keepalive的情况，判断方法如果keepalive生效应当减少tcp握手情况，socks增加，我修改tomcat7711后的情况如下：

```
$ for i in 11 22 33 44; do sudo nice /usr/sbin/tcpdump -n -i lo tcp port 77${i} -c 10000 | perl -nae '$h{$F[5]}++ if $F[5]=~/F/}{printf "%s %s\n\n",$h{$_},$_ for keys%h'; done
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20282 packets received by filter
232 packets dropped by kernel
44 F

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20270 packets received by filter
226 packets dropped by kernel
10 F

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20300 packets received by filter
258 packets dropped by kernel
24 F

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20331 packets received by filter
282 packets dropped by kernel
22 F
```

调整tomcat回原来的设置后

```
$ for i in 11 22 33 44; do sudo nice /usr/sbin/tcpdump -n -i lo tcp port 77${i} -c 10000 | perl -nae '$h{$F[5]}++ if $F[5]=~/F/}{printf "%s %s\n\n",$h{$_},$_ for keys%h'; done
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20284 packets received by filter
234 packets dropped by kernel
22 F

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20358 packets received by filter
313 packets dropped by kernel
12 F

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20344 packets received by filter
300 packets dropped by kernel
20 F

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 96 bytes
10000 packets captured
20220 packets received by filter
168 packets dropped by kernel
22 F
```

结论如果在upstreams中不声明的话会增加握手发生。

### curl

究竟http有没有实现keepalive，明显的需要查看多页面访问时，是否使用一个[connect](http://serverfault.com/questions/199434/how-do-i-make-curl-use-keepalive-from-the-command-line)
