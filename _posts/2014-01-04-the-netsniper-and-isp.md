---
layout: post
title: "the NetSniper and isp"
category: network
tags: [network, isp, netsniper]
---
{% include JB/setup %}

##电信限路由检测路由最新最全面方案

[ 原文 ] ( http://itbbs.pconline.com.cn/network/11607075.html )

##NetSniper网络尖兵

电信运营商是如何发现我们进行ADSL共享的呢？据相关人士透露，此前电信经常使用的产品包括网络尖兵、星空极速和南京信风，特别是网络尖兵最为常用。网络尖兵工作原理
NetSniper网络尖兵是上海上大雷克网络系统有限公司开发的网络接入检测及控制器。它可以自动检测出网络中私自架设的代理服务器系统或非法路由器，并对通过非法代理服务器的IP包以及流向非法路由器的IP包进行控制。
网络尖兵原来采用的检测技术主要是：
1、检查从下级IP出来的IP包的IP-ID是否是连续的，如果不是连续的，则判定下级使用了nat。
2、检查从下级IP出来的IP包的ttl值是否是32、64、128这几个值，如果不是，刚判定下级使用了nat。
3、检查从下级IP出来的http请求包中是否包含有proxy的字段，如果有，则下级用了http代理。
由于检测和防检查技术的对抗升级，现在可能增加了检测的内容：
一、通过行为统计：
1. 在三秒内同一IP对两个以上的网站进行Request，将此IP定位透过NAT进行传输。
2. 在两秒内，若同一IP对同一个网站，进行两次以上的Request，将此IP定位透过NAT进行传输。
二、深度检测数据包内容:
1.检测并发连接数量
2.检测下级IP出来的QQ号码数量,如果同时有5个QQ号,则判定为共享.
3.更多的检测方法
新出现的检测技术
随着市场发展，现在也有城市热点等公司提供了新的技术和方案，常用的技术有某些公司采取的技术有轨迹检测法、时钟偏移检测法和应用特征检测法。
方法之一 ID（identification）轨迹检测法：
对来自某个源IP地址的TCP连接中，IP头中的16位标识（identification），对于某个windows用户，其 identification随着用户发送的IP包的数量增加而逐步增加，如果在一段时间后，发现某个源IP地址，如图所示，有三段 identification在连续变化，则说明该“黑户”此时最少有三个用户在同时使用宽带。
方法之二时钟偏移检测法：
不同的主机物理时钟偏移不同，网络协议栈时钟与物理时钟存在对应关系；不同的主机发送报文的频率因此与时钟存在一定统计对应关系；通过特定的频谱分析算法，发现不同的网络时钟偏移来确定不同的主机。
方法之三应用特征检测法：
数据报文中的HTTP报头中的User－agent字段因操作系统版本、IE版本和布丁的不同而不同。因此通过分析不同的HTTP报头数而确定主机数。另外对于一台主机同一时间只能登录一个MSN帐号，据此分析可判断主机数。Windows update 报文里也包含一些操作系统版本信息，也可以据此计算主机数。
通过以上三种方法就能很准确地非法接入的宽带用户地主机数，无论其采用共用NAT、共用Proxy、或分时段共用帐号上网（包括ADSL和LAN上网两种模式），该非法接入监控系统，都能得到IP地址与所携带用户数的准确对应关系，借助于Radius论证报文，再将它转换为用户帐号与所携带用户数的对应关系。当然，由于本方案采用了多个指标来综合分析，为排除干扰提高准确性，并不实时提供这种对应关系，而是采用按天/周/月提供统计报表的形式，将结果提交给运营商的相关部门。

##星空极速 （社交工程学）

派员工上门，借口网络升级或查杀病毒等，为用户安装该软件。用户安装并运行该软件后，局端密码被更改， 原来系统自带的拨号工具无法使用（提示用户名密码错误），多用户通过路由器共享上网也被限制，部分地区 甚至会弹出无法屏蔽的小广告窗口，卸载“极速星空”软件也不能重新恢复到原来的状态 


##tcpip协议

有很多东西可利用来检测nat后的主机信息，可用的手段很多，根本不需要扫描用户，在线路上监听就行，既所谓的被动指纹技术按信风网站的说法，L2到L7都利用了，这样的话，低层可用被动指纹技术，高层可用绿色上网那一套，向用户发送欺骗cookie，这个根本躲不过去，除非浏览器关掉cookie，但这样浏览网页会很难受，很不幸绿色上网设备也是南京信风出的……那套设备里肯定整合了这个技术


1.在web访问中强行插入小的探出窗口来设定cookie和判断cookie。如果几台共享上网的机器都看了网页的话，可以根据一个ip地址设置了cookie以后，再检测的时候看有没有cookie来判断是不是多台机器上网。不过这种办法只能是辅助判断手段，因为客户端可能禁止cookie，也可能不上web。

2.ip数据包的序列号。ip协议中对数据包定义有连续变化的序列号，如果有几台电脑同时上网，则ip序列号会有较大的跳跃。这种检测办法要对所有的网络流量检测，消耗比较大。不过，ip序列号本身对网络通信的过程没什么影响，把每台机器的ip序列号都固定下来就可以防范这种检测手段了 

3. 使用了多种方式进行检测，包括TCP包的TTL数值、Http User-Agent 系统OS指纹、并发连接数、MAC地址、SNMP检测等等。想避开检测还真是有点难。
关于TCP包的TTL数值问题，一个TCP包每过一个路由会减1，这个倒好解决，可以在QEL服务器上插入一条iptables指令，将OUTPUT输出的包的TTL统一固定为64或者128即可。
还有TCP包的ID的检测，这个比较难办，这需要修改底层协议，重新改内核才有可能。
Http User-Agent可以在某些浏览区里面修改将每个TCP的包头中的可选扩展段用来打标每台机器的时间戳，想必每台机器的时间不会都调得如此精准，每个机器发出的时间戳的误差不会完全相同，利用这个时间戳也可以大致判断内网的机器数量。打乱IPID的发包规律，或者顺序或者分散IPID就能使电信的检测系统失效，将机器的时间戳没掉或者用Internet时间同步DNS 和http会话劫持和并发连接数的检测正常状况下也无法避开大致是你发出http请求，电信截获该请求，伪装目标服务器返回定制的数据给浏览器，浏览器隐藏打开连接至电信服务器报告从浏览器获取的信息，最后电信将连接重定向至目标服务器完成正常连接还有丢弃WEB真实IP返回电信的IP
DNS 劫持类似于GFW和Push广告业务当用户上网以后就自动推送电信广告,或和查处代理上网相结合,向"犯规"的客户端推送警告信息.一般来说该系统是放置在宽带接入服务器（DSLAM）的后面