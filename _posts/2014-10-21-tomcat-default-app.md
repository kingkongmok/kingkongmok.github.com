---
layout: post
title: "tomcat default app"
category: linux
tags: [tomcat, application, location]
---
{% include JB/setup %}

例如我需要访问 ***http://localhost/*** 的时候，希望它会去 /webapps/exampls/

### [更改root app的方法](http://stackoverflow.com/questions/715506/tomcat-6-how-to-change-the-root-application)

首先当然是看看catanila.out日志，弄清楚到底是采用哪个$catalina.home

```
Oct 21, 2014 5:23:11 PM org.apache.catalina.core.AprLifecycleListener init
INFO: The APR based Apache Tomcat Native library which allows optimal performance in production environments was not found on the java.library.path: /opt/icedtea-bin-6.1.13.3/jre/lib/amd64/server:/opt/icedtea-bin-6.1.13.3/jre/lib/amd64:/opt/icedtea-bin-6.1.13.3/jre/../lib/amd64:/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
Oct 21, 2014 5:23:11 PM org.apache.coyote.AbstractProtocol init
INFO: Initializing ProtocolHandler ["http-bio-8080"]
Oct 21, 2014 5:23:11 PM org.apache.coyote.AbstractProtocol init
INFO: Initializing ProtocolHandler ["ajp-bio-8009"]
Oct 21, 2014 5:23:11 PM org.apache.catalina.startup.Catalina load
INFO: Initialization processed in 759 ms
Oct 21, 2014 5:23:11 PM org.apache.catalina.core.StandardService startInternal
INFO: Starting service Catalina
Oct 21, 2014 5:23:11 PM org.apache.catalina.core.StandardEngine startInternal
INFO: Starting Servlet Engine: Apache Tomcat/7.0.42-gentoo
Oct 21, 2014 5:23:11 PM org.apache.catalina.startup.HostConfig deployDescriptor
INFO: Deploying configuration descriptor /etc/tomcat-7/Catalina/localhost/docs.xml
Oct 21, 2014 5:23:12 PM org.apache.catalina.startup.HostConfig deployDescriptor
INFO: Deploying configuration descriptor /etc/tomcat-7/Catalina/localhost/manager.xml
Oct 21, 2014 5:23:12 PM org.apache.catalina.startup.HostConfig deployDescriptor
INFO: Deploying configuration descriptor /etc/tomcat-7/Catalina/localhost/host-manager.xml
Oct 21, 2014 5:23:12 PM org.apache.catalina.startup.HostConfig deployDescriptor
INFO: Deploying configuration descriptor /etc/tomcat-7/Catalina/localhost/examples.xml
Oct 21, 2014 5:23:12 PM org.apache.catalina.startup.HostConfig deployDirectory
INFO: Deploying web application directory /var/lib/tomcat-7/webapps/ROOT
Oct 21, 2014 5:23:12 PM org.apache.coyote.AbstractProtocol start
INFO: Starting ProtocolHandler ["http-bio-8080"]
Oct 21, 2014 5:23:12 PM org.apache.coyote.AbstractProtocol start
INFO: Starting ProtocolHandler ["ajp-bio-8009"]
Oct 21, 2014 5:23:12 PM org.apache.catalina.startup.Catalina start
INFO: Server startup in 816 ms
```

所以，在gentoo的tomcat7中，需要的设置/etc/tomcat-7/Catalina/localhost/ROOT.xml，根据的是[这个](http://tomcat.apache.org/tomcat-7.0-doc/config/context.html#Defining_a_context)

```
$ sudo cat /etc/tomcat-7/Catalina/localhost/ROOT.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="${catalina.home}/webapps/examples" />
```

那么，***curl localhost/*** 的时候，就是读取 ***"${catalina.home}/webapps/examples"***。
