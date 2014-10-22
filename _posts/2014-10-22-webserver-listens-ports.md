---
layout: post
title: "webserver listens ports"
category: linux
tags: [nginx, tomcat, port]
---
{% include JB/setup %}

需要webserver监听多于一个端口的方法，注意nginx那个是一个http，一个https。

### [tomcat](http://stackoverflow.com/questions/15231052/running-tomcat-server-on-two-different-ports)

```
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
<Connector port="8081" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8444" />
```

```bash
$ sudo cat /var/log/tomcat-7/catalina.2014-10-22.log
Oct 22, 2014 11:14:33 AM org.apache.catalina.util.SessionIdGenerator createSecureRandom
INFO: Creation of SecureRandom instance for session ID generation using [SHA1PRNG] took [23,748] milliseconds.
Oct 22, 2014 11:14:33 AM org.apache.catalina.startup.HostConfig deployDescriptor
INFO: Deploying configuration descriptor /etc/tomcat-7/Catalina/localhost/manager.xml
Oct 22, 2014 11:14:33 AM org.apache.catalina.startup.HostConfig deployDescriptor
INFO: Deploying configuration descriptor /etc/tomcat-7/Catalina/localhost/host-manager.xml
Oct 22, 2014 11:14:33 AM org.apache.catalina.startup.HostConfig deployDescriptor
INFO: Deploying configuration descriptor /etc/tomcat-7/Catalina/localhost/examples.xml
Oct 22, 2014 11:14:33 AM org.apache.catalina.startup.HostConfig deployDirectory
INFO: Deploying web application directory /var/lib/tomcat-7/webapps/ROOT
Oct 22, 2014 11:14:33 AM org.apache.coyote.AbstractProtocol start
INFO: Starting ProtocolHandler ["http-bio-8080"]
Oct 22, 2014 11:14:33 AM org.apache.coyote.AbstractProtocol start
INFO: Starting ProtocolHandler ["http-bio-8088"]
Oct 22, 2014 11:14:33 AM org.apache.coyote.AbstractProtocol start
INFO: Starting ProtocolHandler ["ajp-bio-8009"]
Oct 22, 2014 11:14:33 AM org.apache.catalina.startup.Catalina start
INFO: Server startup in 24544 ms
```

### nginx

```
    server {

        listen       8090;
        listen       8443   ssl;
        server_name  servername;


        ssl_certificate /_TEST_ssl.pem;
        ssl_certificate_key /_TEST_ssl.key;
        ...
        ...
    }
```
