---
layout: post
title: "tomcat and war"
category: linux
tags: [tomcat, war]
---
{% include JB/setup %}

虚拟主机(多域名绑定到同一IP)

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
