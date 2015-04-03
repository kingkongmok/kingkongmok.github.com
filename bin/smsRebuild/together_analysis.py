#!/usr/bin/env python
# -*- coding:UTF-8 -*-

import os,sys,re
import time
logTime = time.strftime('%Y-%m-%d',time.localtime(time.time()-24*60*60))

logMon = ['/home/logs/smsmw/172.16.200.2/together/monitoring.log.'+logTime,\
          '/home/logs/smsmw/172.16.200.9/together/monitoring.log.'+logTime,\
          '/home/logs/smsmw/172.16.200.8/together/monitoring.log.'+logTime,]

logTog = ['/home/logs/smsmw/172.16.200.2/together/together.log.'+logTime,\
          '/home/logs/smsmw/172.16.200.9/together/together.log.'+logTime,\
          '/home/logs/smsmw/172.16.200.8/together/together.log.'+logTime,]

TogDic = {'[GD]queryPhoneState':{'explain':'用户手机信息查询','successe':'\[GD\]Successed to query mobileState'},\
          '[GD]accountQuery':{'explain':'用户话费查询','successe':'\[GD\]successed to get availBalance'},\
          '[GD]integralQuery':{'explain':'用户积分查询','successe':'\[GD\]Successed to get integral'},\
          '[GD]businessInfoquery':{'explain':'用户已开通业务查询','successe':'\[GD\]Successed to get businessInfo'},\
          '[GD]packagequery':{'explain':'用户套餐使用情况查询','successe':'\[GD\]Successed to query packageInfo'},\
          '[GD]productOrder':{'explain':'业务办理','successe':'\[GD\]Successed to order or unorder'},\
          '[GD]smsAuthCodeSend':{'explain':'短信验证码下发','successe':'\[GD\]Sucessed to send smsCode'},\
          '[GD]SmsAuthCodeCheck':{'explain':'短信验证码验证','successe':'\[GD\]Sucessed to check smsAuthCode'},\
          '[HN]queryBalance':{'explain':'用户话费查询','successe':'\[HN\]successed to query balance'},\
          '[HN]queryIntegral':{'explain':'用户积分查询','successe':'\[HN\]successed to query integral'},\
          '[HN]queryBusinessInfo':{'explain':'用户已开通业务查询','successe':'\[HN\]successed to query businessInfo'},\
          '[HN]queryPackage':{'explain':'用户套餐使用情况查询','successe':'\[HN\]successed to query packageInfo'},\
          '[HN]queryBillInfo':{'explain':'用户账单信息查询','successe':'\[HN\]Success to get bills'},\
          'isBindFetion':{'explain':'获取与飞信绑定状态','successe':'JudgeBindFetionServiceImpl:144]resultCode:200'},\
          'getFetionFriends':{'explain':'获取飞信好友','successe':'FetionFriendsServiceImpl:155]successed to unpack'},\
          'sendMessage':{'explain':'向飞信好友发送消息','successe':'MessageSendServiceImpl:142]resultCode:200'},\
          'fetionBarCorrelationService.getBindFetionInfo':{'explain':'飞信绑定邮箱','successe':'user:bindFetion successed'},\
          'fetionBarCorrelationService.getFetionLoginInfo':{'explain':'获取飞信登录凭证接口','successe':'successed to get fetion login info'},\
          'fetionSpaceMSG':{'explain':'获取飞信空间未读消息数','successe':'successed to get fetionSpaceMSG'},\
          'getCredential':{'explain':'获取飞信空间登录c值','successe':'successed to get fetionC'},\
          'getWeiboInfo':{'explain':'获取移动微博最新动态信息','successe':'sucessed to get weiboInfo'}}
statisDic = {}

if os.path.isfile('/tmp/together_analysis.html'):
    os.remove("/tmp/together_analysis.html")

for mlog in logMon:
    monitLog = open(mlog,'r')
    while True:
        lines = monitLog.readlines(5000)
        if not lines:
            break
        for line in lines:
            fields = line.split('|')
            runTime = fields[7]
            actionName = fields[11]
            if re.search(r'RunTime',runTime,re.I):
                interfaceName = actionName.split('=')[1]
                time = int(runTime.split('=')[1].strip())
                if interfaceName in TogDic.keys():
                    statisDic.setdefault(interfaceName,{'explain':TogDic[interfaceName]['explain'],\
                    'total':0,'lt300':0,'successe':0})['total'] += 1
                    if time > 3000 :
                        statisDic[interfaceName]['lt300']+=1

    monitLog.close()

for tlog in logTog:
    togLog = open(tlog,'r')
    while True:
        lines = togLog.readlines(5000)
        if not lines:
            break
        for line in lines:
            for key in TogDic.keys():
                success = TogDic[key]['successe']
                pattern = re.compile(r".+(%s).+"%(success),re.I)
                if pattern.match(line):
                    statisDic[key]['successe']+=1
    togLog.close()
print statisDic

#格式化输出
tempLog = open('/tmp/together_analysis.html','a')

formatTable = '<table width="1000" border="1" align="left" cellpadding="0" cellspacing="0">\n\
<tr>\n<td width="300" height="30">接口名称 </td>\n<td width="190">接口说明</td>\n<td width="100">访问总量</td>\n<td width="120">耗时大于3秒次数</td>\n\
<td width="100">成功次数</td>\n<td width="100">失败次数</td>\n<td width="100">成功比例%</td>\n</tr>\n'

tempLog.write(formatTable)

for name in statisDic.keys():
    explain = statisDic[name]['explain']
    total = statisDic[name]['total']
    #lt300 = statisDic[name]['lt300']
    success = statisDic[name]['successe']
    #fail = int(total) - int(success)
    failPer = round(float(success)/float(total),2) * 100
    lt300 = 0    
    fail = 0

    if name == "fetionSpaceMSG":
	   lt300 = int(total) - int(success)
	   fail = statisDic[name]['lt300']
    if name != "fetionSpaceMSG":
       lt300 = statisDic[name]['lt300']
       fail = int(total) - int(success)
    
    table = '<tr><td height="30">%(name)s</td><td>%(explain)s</td><td>%(total)d</td><td>%(lt300)d</td>\
    <td>%(success)d</td><td>%(fail)d</td><td>%(failPer)s</td></tr>' %{'name':name,'explain':explain,'total':total,'lt300':lt300,\
    'success':success,'fail':fail,'failPer':failPer,}
    tempLog.write(table)

tempLog.close()
os.system('/home/appSys/smsRebuild/sbin/together_analysis_py.sh')
