---
layout: post
title: "tomcat and war"
category: linux
tags: [tomcat, war]
---
{% include JB/setup %}

## install

* 查看tomcat目录的RUNNING.txt。
* install jre ，其实可以直接下载JRE，解压即可，不必设置环境。
* install Apache Tomcat， 解压即可。
* 设置${CATALINA_HOME}/bin/setenv.sh设置 ***JRE_HOME*** , ***CATALINA_HOME***

```bash
$ cat /usr/local/tomcat1/bin/setenv.sh 
#!/bin/bash - 
JRE_HOME=/opt/jre1.7.0_21
CATALINA_HOME=/opt/apache-tomcat-7.0.56
```

### Multiple Tomcat Instances

在gentoo的 ***/usr/share/tomcat-7/gentoo/tomcat-instance-manager.bash*** 中，可以直接创建instances，根据这个方法和刚刚的RUNNING.txt，可以得到方法如下：

* 拷贝相应的文件夹到$CATALINA_BASE处， ***conf,temp,logs,webapps,work,bin***
* 修改 ***${CATALINA_BASE}/bin/setenv.sh*** ，在这里除了JRE_HOME, CATALINA_HOME，还需要***CATALINA_BASE***
* 修改 ***${CATALINA_BASE}/conf/server.xml*** ，　主要是修改有关端口的设置，一般包括server, http connector, AJP 等。
* 最好设置一下 `${CATALINA_BASE}/webapps/ROOT` 到相应的app即可

```bash
$ cat /usr/local/tomcat1/bin/setenv.sh 

#!/bin/bash - 
JRE_HOME=/opt/jre1.7.0_21
CATALINA_BASE=/usr/local/tomcat2
CATALINA_HOME=/opt/apache-tomcat-7.0.56
```

```bash
$ sudo diff -u  /usr/local/tomcat2/conf/server.xml /opt/apache-tomcat-7.0.56/conf/server.xml 
--- /usr/local/tomcat2/conf/server.xml  2014-11-04 15:15:23.670352145 +0800
+++ /opt/apache-tomcat-7.0.56/conf/server.xml   2014-09-26 17:15:38.000000000 +0800
@@ -19,7 +19,7 @@
      define subcomponents such as "Valves" at this level.
      Documentation at /docs/config/server.html
  -->
-<Server port="8006" shutdown="SHUTDOWN">
+<Server port="8005" shutdown="SHUTDOWN">
   <!-- Security listener. Documentation at /docs/config/listeners.html
   <Listener className="org.apache.catalina.security.SecurityListener" />
   -->
@@ -67,7 +67,7 @@
          APR (HTTP/AJP) Connector: /docs/apr.html
          Define a non-SSL HTTP/1.1 Connector on port 8080
     -->
-    <Connector port="8082" protocol="HTTP/1.1"
+    <Connector port="8080" protocol="HTTP/1.1"
                connectionTimeout="20000"
                redirectPort="8443" />
     <!-- A "Connector" using the shared thread pool-->
@@ -89,7 +89,7 @@
     -->
 
     <!-- Define an AJP 1.3 Connector on port 8009 -->
-    <Connector port="8010" protocol="AJP/1.3" redirectPort="8443" />
+    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
 
 
     <!-- An Engine represents the entry point (within Catalina) that processesRE_HOME=/opt/jre1.7.0_21
```


### 虚拟主机(多域名绑定到同一IP)

<pre lang="bash">
    <Host name="www.123.com"  appBase="webapps/test" 
         unpackWARs="true" autoDeploy="true">      # name 域名  appBase 虚拟主机主程序目录  
        <Alias>www.456.com</Alias>                 # 其他域名
        <Context path ="" docBase ="/opt/tomcat/webapps/test.war" debug ="0" reloadbale ="true" >         # war文件路径或其他程序路径
                </Context>
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
            prefix="localhost_access_log." suffix=".txt"
            pattern="%h %l %u %t &quot;%r&quot; %s %b" />        # 日志设置
    </Host>
</pre>

appBase和docBase对应的话，可以不需在url上填入模块名称。如果没设置好，则需要填入模块名称本例“/test/”。
