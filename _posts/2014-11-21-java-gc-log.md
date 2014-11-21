---
layout: post
title: "java gc的观察记录"
category: linux
tags: [java, gc, tomcat]
---
{% include JB/setup %}

### tomcat启动后没有访问

* tomcat启动后，`没有访问`的情况，gc不做变化

```
$ sudo jstat -gcutil `pgrep java` 2000 0
  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT   
 23.07   0.00  61.48  77.33  68.89     16    0.070     0    0.000    0.070
 23.07   0.00  61.48  77.33  68.89     16    0.070     0    0.000    0.070
 23.07   0.00  61.48  77.33  68.89     16    0.070     0    0.000    0.070
 23.07   0.00  62.39  77.33  68.89     16    0.070     0    0.000    0.070
```

### 客户端访问
使用curl模拟访问，当然也可以httperf，但我还不知道如何设置uri，所以笨点。

```bash
kk@ins14 ~ $ for i in `seq 10000`; do curl localhost:8080/${i} -s > /dev/null ; done
```

另外途中我尝试添加了访问其他的uri，但结果变化不太明显:

```
kk@ins14 ~ $ for i in `seq 1000000`; do curl localhost:8080/docs/${i} -s > /dev/null ; done
```

```
  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT   
 23.07   0.00  65.08  77.33  68.89     16    0.070     0    0.000    0.070
 23.07   0.00  65.09  77.33  68.89     16    0.070     0    0.000    0.070
 77.50   0.00  29.97  77.33  68.91     18    0.075     0    0.000    0.075
 45.01   0.00  23.11  81.19  69.17     20    0.078     0    0.000    0.078
 68.93   0.00   8.48  82.18  69.36     22    0.081     0    0.000    0.081
 46.91   0.00   5.67  85.88  69.38     24    0.096     0    0.000    0.096
 46.20   0.00   1.54  88.59  69.99     26    0.099     0    0.000    0.099
  0.00  67.85  93.72  88.59  70.21     27    0.101     0    0.000    0.101
  0.00  68.64  93.69  90.67  70.33     29    0.104     0    0.000    0.104
  0.00  69.58  73.60  92.76  70.36     31    0.107     0    0.000    0.107
  0.00  68.25  56.94  94.90  70.37     33    0.111     0    0.000    0.111
  0.00  68.10  71.60  96.99  70.37     35    0.114     0    0.000    0.114
  0.00   0.00  47.43  59.99  70.37     37    0.124     1    0.036    0.160
 47.18   0.00  69.93  59.99  70.37     38    0.126     1    0.036    0.162
  0.00  69.73  97.03  59.99  70.37     39    0.128     1    0.036    0.164
  0.00  69.53  23.88  62.14  70.37     41    0.132     1    0.036    0.168
 69.73   0.00  47.23  63.21  70.37     42    0.134     1    0.036    0.170
  0.00  69.71  71.01  64.28  70.37     43    0.136     1    0.036    0.173
 69.29   0.00  48.80  65.36  70.37     44    0.139     1    0.036    0.175
  0.00  54.88  52.90  66.04  70.37     45    0.140     1    0.036    0.177
 64.77   0.00  61.38  66.71  70.37     46    0.143     1    0.036    0.179
 64.77   0.00  61.38  66.71  70.37     46    0.143     1    0.036    0.179

  0.00  53.87  45.23  94.44  70.40     89    0.259     1    0.036    0.296
 53.99   0.00  50.08  95.10  70.40     90    0.261     1    0.036    0.297
  0.00  43.20  58.22  95.36  70.40     91    0.262     1    0.036    0.299
 57.31   0.00  65.47  95.36  70.40     92    0.265     1    0.036    0.301
  0.00  53.90  71.84  96.19  70.40     93    0.266     1    0.036    0.303
 53.81   0.00  79.70  96.85  70.40     94    0.268     1    0.036    0.304
  0.00  54.02  87.21  97.52  70.40     95    0.270     1    0.036    0.307
 54.30   0.00  94.77  98.19  70.40     96    0.272     1    0.036    0.309
 54.14   0.00   0.00  99.53  70.40     98    0.275     1    0.036    0.312
  0.00   0.00   5.21  54.15  70.40     99    0.277     2    0.112    0.389
 40.30   0.00   6.42  54.15  70.40    100    0.278     2    0.112    0.391
  0.00  54.30  11.43  54.15  70.40    101    0.280     2    0.112    0.392
 54.07   0.00  18.37  54.84  70.40    102    0.281     2    0.112    0.394

 54.36   0.00  35.23  75.75  70.39    414    0.848     6    0.264    1.112
 54.63   0.00  94.14  77.08  70.39    416    0.851     6    0.264    1.115
  0.00  54.57  55.27  79.07  70.39    419    0.856     6    0.264    1.121
 54.42   0.00  16.06  81.07  70.39    422    0.861     6    0.264    1.125
 54.61   0.00  73.00  82.40  70.39    424    0.865     6    0.264    1.130
  0.00  54.63  33.00  84.39  70.39    427    0.871     6    0.264    1.135
  0.00  54.54  98.76  85.73  70.39    429    0.875     6    0.264    1.139
 44.66   0.00  41.89  87.32  70.39    432    0.881     6    0.264    1.145
  0.00  54.54   4.53  88.85  70.39    435    0.886     6    0.264    1.150
  0.00  54.40  67.25  90.18  70.39    437    0.889     6    0.264    1.153
 54.46   0.00  32.33  92.18  70.39    440    0.895     6    0.264    1.159
 54.62   0.00  96.12  93.51  70.39    442    0.898     6    0.264    1.162
  0.00  54.49  61.89  95.50  70.39    445    0.903     6    0.264    1.167
 54.64   0.00  27.15  97.50  70.39    448    0.908     6    0.264    1.172
 54.56   0.00  92.25  98.83  70.39    450    0.911     6    0.264    1.175
  0.00  35.97  56.27  60.00  70.39    453    0.915     7    0.301    1.216
 51.15   0.00  18.50  61.22  70.39    456    0.922     7    0.301    1.222
```

#### 访问直观分析

* 大概2秒做一次ygc
* 好多次后才做一个fgc
* 改小一点的jstat interval参数，也发现是大概2s一次的s0 <-> s1过程，调大也同样的结论
* `E` 给涨到100的时候就给 `O` 涨1，并记一次`ygc`, 做一次s0 <-> s1过程
* `O`要涨的100的时候就做一次fgc，然后`O`下降到60
* TMD P居然可大可小


### 访问停止后

* tomcat启动后，`没有访问`的情况，gc不做变化


### 关闭tomcat

* jstat 返回退出

### 启动tomcat

```
  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT   
 0.00  68.10  71.60  96.99  70.37     35    0.114     0    0.000    0.114j 
 0.00   0.00  47.43  59.99  70.37     37    0.124     1    0.036    0.160j 
47.18   0.00  69.93  59.99  70.37     38    0.126     1    0.036    0.162j 
 0.00  69.73  97.03  59.99  70.37     39    0.128     1    0.036    0.164j 
 0.00  69.53  23.88  62.14  70.37     41    0.132     1    0.036    0.168j 
69.73   0.00  47.23  63.21  70.37     42    0.134     1    0.036    0.170j 
 0.00  69.71  71.01  64.28  70.37     43    0.136     1    0.036    0.173j 
69.29   0.00  48.80  65.36  70.37     44    0.139     1    0.036    0.175j 
 0.00  54.88  52.90  66.04  70.37     45    0.140     1    0.036    0.177j 
64.77   0.00  61.38  66.71  70.37     46    0.143     1    0.036    0.179j 
64.77   0.00  61.38  66.71  70.37     46    0.143     1    0.036    0.179j 
 
 0.00  53.87  45.23  94.44  70.40     89    0.259     1    0.036    0.296k j j 
53.99   0.00  50.08  95.10  70.40     90    0.261     1    0.036    0.297j 
 0.00  43.20  58.22  95.36  70.40     91    0.262     1    0.036    0.299j 
57.31   0.00  65.47  95.36  70.40     92    0.265     1    0.036    0.301j 
 0.00  53.90  71.84  96.19  70.40     93    0.266     1    0.036    0.303j 
53.81   0.00  79.70  96.85  70.40     94    0.268     1    0.036    0.304j 
 0.00  54.02  87.21  97.52  70.40     95    0.270     1    0.036    0.307j 
54.30   0.00  94.77  98.19  70.40     96    0.272     1    0.036    0.309j 
54.14   0.00   0.00  99.53  70.40     98    0.275     1    0.036    0.312j 
 0.00   0.00   5.21  54.15  70.40     99    0.277     2    0.112    0.389j 
40.30   0.00   6.42  54.15  70.40    100    0.278     2    0.112    0.391j 
 0.00  54.30  11.43  54.15  70.40    101    0.280     2    0.112    0.392j 
54.07   0.00  18.37  54.84  70.40    102    0.281     2    0.112    0.394j 
 
54.36   0.00  35.23  75.75  70.39    414    0.848     6    0.264    1.112j 
54.63   0.00  94.14  77.08  70.39    416    0.851     6    0.264    1.115j 
 0.00  54.57  55.27  79.07  70.39    419    0.856     6    0.264    1.121j 
54.42   0.00  16.06  81.07  70.39    422    0.861     6    0.264    1.125j 
54.61   0.00  73.00  82.40  70.39    424    0.865     6    0.264    1.130j 
 0.00  54.63  33.00  84.39  70.39    427    0.871     6    0.264    1.135j 
 0.00  54.54  98.76  85.73  70.39    429    0.875     6    0.264    1.139j 
44.66   0.00  41.89  87.32  70.39    432    0.881     6    0.264    1.145j 
 0.00  54.54   4.53  88.85  70.39    435    0.886     6    0.264    1.150j 
 0.00  54.40  67.25  90.18  70.39    437    0.889     6    0.264    1.153j 
54.46   0.00  32.33  92.18  70.39    440    0.895     6    0.264    1.159j 
54.62   0.00  96.12  93.51  70.39    442    0.898     6    0.264    1.162j 
 0.00  54.49  61.89  95.50  70.39    445    0.903     6    0.264    1.167j 
54.64   0.00  27.15  97.50  70.39    448    0.908     6    0.264    1.172j 
54.56   0.00  92.25  98.83  70.39    450    0.911     6    0.264    1.175j 
 0.00  35.97  56.27  60.00  70.39    453    0.915     7    0.301    1.216j 
51.15   0.00  18.50  61.22  70.39    456    0.922     7    0.301    1.222j 
```

* 启动完毕后趋向静止

### catalina的参数

* gentoo测试中居然找不到……,已经搜索catalina home和catalina base。这个需要落实。在其他设置里面一般在base上做的。
* 那就看看默认情况

```
kk@ins14 /usr/share/tomcat-7/conf $ ps -ef | grep java | grep catalin.*home
tomcat   20691     1  0 11:43 ?        00:00:05 /opt/icedtea-bin-6.1.13.3/bin/java -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.util.logging.config.file=/var/lib/tomcat-7-testing/conf/logging.properties -Dcatalina.base=/var/lib/tomcat-7-testing -Dcatalina.home=/usr/share/tomcat-7 -Djava.io.tmpdir=/var/tmp/tomcat-7-testing -classpath /usr/share/tomcat-7/bin/bootstrap.jar:/usr/share/tomcat-7/bin/tomcat-juli.jar:/usr/share/tomcat-7/lib/annotations-api.jar:/usr/share/tomcat-7/lib/catalina-ant.jar:/usr/share/tomcat-7/lib/catalina-ha.jar:/usr/share/tomcat-7/lib/catalina.jar:/usr/share/tomcat-7/lib/catalina-tribes.jar:/usr/share/tomcat-7/lib/jasper-el.jar:/usr/share/tomcat-7/lib/jasper.jar:/usr/share/tomcat-7/lib/tomcat-api.jar:/usr/share/tomcat-7/lib/tomcat-coyote.jar:/usr/share/tomcat-7/lib/tomcat-i18n-es.jar:/usr/share/tomcat-7/lib/tomcat-i18n-fr.jar:/usr/share/tomcat-7/lib/tomcat-i18n-ja.jar:/usr/share/tomcat-7/lib/tomcat-jdbc.jar:/usr/share/tomcat-7/lib/tomcat-util.jar:/usr/share/eclipse-ecj-4.4/lib/eclipse-ecj.jar:/usr/share/eclipse-ecj-4.4/lib/ecj.jar:/usr/share/tomcat-servlet-api-3.0/lib/el-api.jar:/usr/share/tomcat-servlet-api-3.0/lib/jsp-api.jar:/usr/share/tomcat-servlet-api-3.0/lib/servlet-api.jar org.apache.catalina.startup.Bootstrap start
```

*** 比较大的内存情况

```
$ ps -ef | grep [j]ava
mmSdk    22510     1 32 02:26 ?        04:45:07 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.file=/opt/mmSdk/tomcat-7711/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms4096m -Xmx8192m -Xmn1024m -XX:PermSize=128m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=16 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=85 -XX:+PrintGCDetails -Xloggc:../logs/gc.log -Djava.endorsed.dirs=/opt/mmSdk/tomcat-7711/endorsed -classpath /opt/mmSdk/tomcat-7711/bin/bootstrap.jar:/opt/mmSdk/tomcat-7711/bin/tomcat-juli.jar -Dcatalina.base=/opt/mmSdk/tomcat-7711 -Dcatalina.home=/opt/mmSdk/tomcat-7711 -Djava.io.tmpdir=/opt/mmSdk/tomcat-7711/temp org.apache.catalina.startup.Bootstrap start
mmSdk    22638     1 32 02:26 ?        04:47:47 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.file=/opt/mmSdk/tomcat-7722/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms4096m -Xmx8192m -Xmn1024m -XX:PermSize=128m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=16 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=85 -XX:+PrintGCDetails -Xloggc:../logs/gc.log -Djava.endorsed.dirs=/opt/mmSdk/tomcat-7722/endorsed -classpath /opt/mmSdk/tomcat-7722/bin/bootstrap.jar:/opt/mmSdk/tomcat-7722/bin/tomcat-juli.jar -Dcatalina.base=/opt/mmSdk/tomcat-7722 -Dcatalina.home=/opt/mmSdk/tomcat-7722 -Djava.io.tmpdir=/opt/mmSdk/tomcat-7722/temp org.apache.catalina.startup.Bootstrap start
mmSdk    22701     1 33 02:26 ?        04:49:38 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.file=/opt/mmSdk/tomcat-7733/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms4096m -Xmx8192m -Xmn1024m -XX:PermSize=128m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=16 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=85 -XX:+PrintGCDetails -Xloggc:../logs/gc.log -Djava.endorsed.dirs=/opt/mmSdk/tomcat-7733/endorsed -classpath /opt/mmSdk/tomcat-7733/bin/bootstrap.jar:/opt/mmSdk/tomcat-7733/bin/tomcat-juli.jar -Dcatalina.base=/opt/mmSdk/tomcat-7733 -Dcatalina.home=/opt/mmSdk/tomcat-7733 -Djava.io.tmpdir=/opt/mmSdk/tomcat-7733/temp org.apache.catalina.startup.Bootstrap start
mmSdk    23829     1 32 02:26 ?        04:42:24 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.file=/opt/mmSdk/tomcat-7744/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms4096m -Xmx8192m -Xmn1024m -XX:PermSize=128m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=16 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=85 -XX:+PrintGCDetails -Xloggc:../logs/gc.log -Djava.endorsed.dirs=/opt/mmSdk/tomcat-7744/endorsed -classpath /opt/mmSdk/tomcat-7744/bin/bootstrap.jar:/opt/mmSdk/tomcat-7744/bin/tomcat-juli.jar -Dcatalina.base=/opt/mmSdk/tomcat-7744 -Dcatalina.home=/opt/mmSdk/tomcat-7744 -Djava.io.tmpdir=/opt/mmSdk/tomcat-7744/temp org.apache.catalina.startup.Bootstrap start

$ ps -C java v
  PID TTY      STAT   TIME  MAJFL   TRS   DRS   RSS %MEM COMMAND
22510 ?        Sl   285:41     47     2 9681809 1495516  1.1 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.fil
22638 ?        Sl   288:20     20     2 9742761 1573020  1.1 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.fil
22701 ?        Sl   290:12     20     2 9767689 1657760  1.2 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.fil
23829 ?        Sl   282:56     20     2 9745629 1481392  1.1 /opt/mmSdk/jdk1.7.0_51/bin/java -Djava.util.logging.config.fil

$ jstat -gcutil 22510 2000 5
  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT   
  8.04   0.00  21.47  10.04  22.07   2974   92.026     0    0.000   92.026
  8.04   0.00  39.96  10.04  22.07   2974   92.026     0    0.000   92.026
  8.04   0.00  57.71  10.04  22.07   2974   92.026     0    0.000   92.026
  8.04   0.00  75.52  10.04  22.07   2974   92.026     0    0.000   92.026
  8.04   0.00  91.11  10.04  22.07   2974   92.026     0    0.000   92.026
```

居然没有gc，霸气。

### tomcat开启天数不同的gc情况

```
$ ps -C java -o pid,pcpu,rss,etime
  PID %CPU   RSS     ELAPSED
12420  3.3 1122968 189-06:08:13
12914  0.6 893552   16:44:43

$ jstat -gcutil 12420 2000 0
  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT   
 26.77   0.00  98.26  10.98  84.00 423400 8074.452  4663 1584.535 9658.988
  0.00  30.48   4.00  11.04  84.07 423401 8074.476  4663 1584.535 9659.011

$ jstat -gcutil 12420 2000 5
  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT   
  0.00  30.48   8.01  11.04  84.14 423401 8074.476  4663 1584.535 9659.011
  0.00  30.48  12.01  11.04  84.20 423401 8074.476  4663 1584.535 9659.011
  0.00  30.48  16.01  11.04  84.27 423401 8074.476  4663 1584.535 9659.011
  0.00  30.48  20.01  11.04  84.34 423401 8074.476  4663 1584.535 9659.011
  0.00  30.48  24.01  11.04  84.38 423401 8074.476  4663 1584.535 9659.011

$ jstat -gcutil 12914 2000 5
  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT   
  0.00  24.39  99.03   8.74  38.03    153    4.881    17    5.839   10.720
  0.00  24.39  99.03   8.74  38.03    153    4.881    17    5.839   10.720
 23.70   0.00   0.77   8.74  38.03    154    4.909    17    5.839   10.747
 23.70   0.00   8.33   8.74  38.03    154    4.909    17    5.839   10.747
 23.70   0.00   8.34   8.74  38.03    154    4.909    17    5.839   10.747

$ ps -ef | grep [j]ava
800      12420     1  3 May16 ?        6-08:20:33 /home/appSys/smsRebuild/jdk/bin/java -Djava.util.logging.config.file=/home/appSys/smsRebuild/tomcat_HtmlService/conf/logging.properties -Xms1024m -Xmx2048m -Xmn640m -XX:PermSize=192m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=4 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=85 -XX:+PrintGCDetails -Xloggc:../logs/gc.log -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.endorsed.dirs=/home/appSys/smsRebuild/tomcat_HtmlService/endorsed -classpath /home/appSys/smsRebuild/tomcat_HtmlService/bin/bootstrap.jar:/home/appSys/smsRebuild/tomcat_HtmlService/bin/tomcat-juli.jar -Dcatalina.base=/home/appSys/smsRebuild/tomcat_HtmlService -Dcatalina.home=/home/appSys/smsRebuild/tomcat_HtmlService -Djava.io.tmpdir=/home/appSys/smsRebuild/tomcat_HtmlService/temp org.apache.catalina.startup.Bootstrap start
800      12914     1  0 00:08 ?        00:07:00 /home/appSys/smsRebuild/jdk/bin/java -Djava.util.logging.config.file=/home/appSys/smsRebuild/tomcat_7.0.20/conf/logging.properties -Xms1024m -Xmx2048m -Xmn640m -XX:PermSize=192m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=4 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=85 -XX:+PrintGCDetails -Xloggc:../logs/gc.log -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.endorsed.dirs=/home/appSys/smsRebuild/tomcat_7.0.20/endorsed -classpath /home/appSys/smsRebuild/tomcat_7.0.20/bin/bootstrap.jar:/home/appSys/smsRebuild/tomcat_7.0.20/bin/tomcat-juli.jar -Dcatalina.base=/home/appSys/smsRebuild/tomcat_7.0.20 -Dcatalina.home=/home/appSys/smsRebuild/tomcat_7.0.20 -Djava.io.tmpdir=/home/appSys/smsRebuild/tomcat_7.0.20/temp org.apache.catalina.startup.Bootstrap start
```
