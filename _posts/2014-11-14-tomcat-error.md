---
layout: post
title: "tomcat error"
category: linux
tags: [tomcat, jstack, ps]
---
{% include JB/setup %}

### errors 
在测试nginx-tomcat{upstreams}的时候，发现tomcat出现`Java heap space`的报错

```
$ tail -f ./tomcat2/logs/catalina.out 
    at org.apache.coyote.http11.Http11Protocol$Http11ConnectionHandler.createProcessor(Http11Protocol.java:103)
    at org.apache.coyote.AbstractProtocol$AbstractConnectionHandler.process(AbstractProtocol.java:586)
    at org.apache.tomcat.util.net.JIoEndpoint$SocketProcessor.run(JIoEndpoint.java:314)
    at java.util.concurrent.ThreadPoolExecutor.runWorker(Unknown Source)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(Unknown Source)
    at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61)
    at java.lang.Thread.run(Unknown Source)
Exception in thread "http-bio-8082-exec-2" java.lang.OutOfMemoryError: Java heap space
Exception in thread "http-bio-8082-exec-3" java.lang.OutOfMemoryError: Java heap space
Exception in thread "http-bio-8082-exec-5" java.lang.OutOfMemoryError: Java heap space
```

### setting
在用的tomcat是下载于apache-tomcat的官网。和默认的没过多区别

```
$ sudo diff -u tomcat2/conf/server.xml /opt/apache-tomcat-7.0.56/conf/server.xml 
--- tomcat2/conf/server.xml 2014-11-13 14:19:39.440211126 +0800
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
@@ -67,10 +67,8 @@
          APR (HTTP/AJP) Connector: /docs/apr.html
          Define a non-SSL HTTP/1.1 Connector on port 8080
     -->
-    <Connector port="8082" protocol="HTTP/1.1"
+    <Connector port="8080" protocol="HTTP/1.1"
                connectionTimeout="20000"
-               keepAliveTimeout="300000"
-               maxKeepAliveRequests="512"
                redirectPort="8443" />
     <!-- A "Connector" using the shared thread pool-->
     <!--
@@ -91,9 +89,7 @@
     -->
 
     <!-- Define an AJP 1.3 Connector on port 8009 -->
-    <!--
-    <Connector port="8010" protocol="AJP/1.3" redirectPort="8443" />
-    -->
+    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
 
 
     <!-- An Engine represents the entry point (within Catalina) that processes`
```

### running

```
$ ps -C java u | cat
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      4377 11.2 31.4 1000748 322356 pts/0  Sl   11:33   2:36 /opt/jre1.7.0_21/bin/java -Djava.util.logging.config.file=/usr/local/tomcat2/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.endorsed.dirs=/opt/apache-tomcat-7.0.56/endorsed -classpath /opt/apache-tomcat-7.0.56/bin/bootstrap.jar:/usr/local/tomcat2/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat2 -Dcatalina.home=/opt/apache-tomcat-7.0.56 -Djava.io.tmpdir=/usr/local/tomcat2/temp org.apache.catalina.startup.Bootstrap start
```

### threads

```
$ ps -C java H | wc
     25     365   12179
```

```
$ sudo jstack 4377 | grep -vP "^\s+at"
2014-11-14 11:57:43
Full thread dump Java HotSpot(TM) 64-Bit Server VM (23.21-b01 mixed mode):

"Attach Listener" daemon prio=10 tid=0x00007f24f400b800 nid=0x12c7 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"http-bio-8082-exec-15" daemon prio=10 tid=0x0000000000617000 nid=0x1209 waiting on condition [0x00007f24f2dfc000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-14" daemon prio=10 tid=0x00007f2504043000 nid=0x1207 waiting on condition [0x00007f24f3317000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-13" daemon prio=10 tid=0x00007f24ec17a800 nid=0x1204 waiting on condition [0x00007f24f27f6000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-12" daemon prio=10 tid=0x00007f24f400a800 nid=0x1203 waiting on condition [0x00007f24f28f7000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-11" daemon prio=10 tid=0x00007f24f81e6800 nid=0x1202 waiting on condition [0x00007f24f3115000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-10" daemon prio=10 tid=0x00007f24f4001800 nid=0x1135 waiting on condition [0x00007f24f26f5000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-7" daemon prio=10 tid=0x00007f24e8001800 nid=0x1132 waiting on condition [0x00007f24f29f8000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-6" daemon prio=10 tid=0x0000000000603000 nid=0x1131 waiting on condition [0x00007f24f2af9000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-4" daemon prio=10 tid=0x00007f2504031800 nid=0x112f waiting on condition [0x00007f24f2cfb000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-exec-1" daemon prio=10 tid=0x00007f2500002800 nid=0x112c waiting on condition [0x00007f24f3216000]
   java.lang.Thread.State: WAITING (parking)
    - parking to wait for  <0x00000000f0dcec10> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)

"http-bio-8082-AsyncTimeout" daemon prio=10 tid=0x00007f250c443000 nid=0x1128 waiting on condition [0x00007f24f2f13000]
   java.lang.Thread.State: TIMED_WAITING (sleeping)

"http-bio-8082-Acceptor-0" daemon prio=10 tid=0x00007f250c442000 nid=0x1127 runnable [0x00007f24f3014000]
   java.lang.Thread.State: RUNNABLE

"GC Daemon" daemon prio=10 tid=0x00007f250c390800 nid=0x1123 in Object.wait() [0x00007f24f388a000]
   java.lang.Thread.State: TIMED_WAITING (on object monitor)
    - waiting on <0x00000000f07ead10> (a sun.misc.GC$LatencyLock)
    - locked <0x00000000f07ead10> (a sun.misc.GC$LatencyLock)

"Service Thread" daemon prio=10 tid=0x00007f250c0e1800 nid=0x1121 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"C2 CompilerThread1" daemon prio=10 tid=0x00007f250c0df000 nid=0x1120 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"C2 CompilerThread0" daemon prio=10 tid=0x00007f250c0dc800 nid=0x111f waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"Signal Dispatcher" daemon prio=10 tid=0x00007f250c0da800 nid=0x111e runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"Finalizer" daemon prio=10 tid=0x00007f250c091000 nid=0x111d in Object.wait() [0x00007f25086d6000]
   java.lang.Thread.State: WAITING (on object monitor)
    - waiting on <0x00000000f067a820> (a java.lang.ref.ReferenceQueue$Lock)
    - locked <0x00000000f067a820> (a java.lang.ref.ReferenceQueue$Lock)

"Reference Handler" daemon prio=10 tid=0x00007f250c08f000 nid=0x111c in Object.wait() [0x00007f25087d7000]
   java.lang.Thread.State: WAITING (on object monitor)
    - waiting on <0x00000000f067a8b8> (a java.lang.ref.Reference$Lock)
    - locked <0x00000000f067a8b8> (a java.lang.ref.Reference$Lock)

"main" prio=10 tid=0x00007f250c009000 nid=0x111a runnable [0x00007f25128ea000]
   java.lang.Thread.State: RUNNABLE

"VM Thread" prio=10 tid=0x00007f250c087800 nid=0x111b runnable 

"VM Periodic Task Thread" prio=10 tid=0x00007f250c0ec800 nid=0x1122 waiting on condition 

JNI global references: 449
```
