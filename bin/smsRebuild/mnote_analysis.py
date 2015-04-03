#!/usr/bin/env python
# -*- coding:UTF-8 -*-

import os,sys,re
import time
logTime = time.strftime('%Y-%m-%d',time.localtime(time.time()-24*60*60))

logMon = ['/home/logs/weblog/172.16.210.51/disk/file/monitor.log.'+logTime,]


TogDic = {'mnoteAuthLogin':{'explain':'彩云笔记鉴权','successe':'IsSucess=true'},\
          'mnoteGetNotes':{'explain':'获取所有笔记','successe':'IsSucess=true'},\
          'mnoteCreateNote':{'explain':'创建笔记','successe':'IsSucess=true'},\
          'updateNote':{'explain':'更新笔记','successe':'IsSucess=true'},\
          'mnoteDeleteNote':{'explain':'删除笔记','successe':'IsSucess=true'},\
          'mnoteSearchNote':{'explain':'搜索笔记','successe':'IsSucess=true'},\
          'mnoteGetNote':{'explain':'单个笔记查看','successe':'IsSucess=true'},\
          'mnoteUpload':{'explain':'笔记附件上传','successe':'IsSucess=true'},\
          'mnoteDownload':{'explain':'笔记附件下载','successe':'IsSucess=true'},\
          'mnoteThumbnail':{'explain':'缩略图','successe':'IsSucess=true'}}

statisDic = {}

if os.path.isfile('/tmp/mnote_analysis.html'):
    os.remove("/tmp/mnote_analysis.html")

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
            IsSucess = fields[9]
            if re.search(r'RunTime',runTime,re.I):
                interfaceName = actionName.split('=')[1]
                time = int(runTime.split('=')[1].strip())
                if interfaceName in TogDic.keys():
                    statisDic.setdefault(interfaceName,{'explain':TogDic[interfaceName]['explain'],\
                    'total':0,'lt300':0,'successe':0})['total'] += 1
                    if time > 3000 :
                        statisDic[interfaceName]['lt300']+=1
                    if IsSucess == "IsSucess=true" :
                        statisDic[interfaceName]['successe']+=1
                    

    monitLog.close()

print statisDic

#格式化输出
tempLog = open('/tmp/mnote_analysis.html','a')

formatTable = '<table width="1000" border="1" align="left" cellpadding="0" cellspacing="0">\n\
<tr>\n<td width="300" height="30">接口名称 </td>\n<td width="190">接口说明</td>\n<td width="100">访问总量</td>\n<td width="120">耗时大于3秒次数</td>\n\
<td width="100">成功次数</td>\n<td width="100">失败次数</td>\n<td width="100">成功比例%</td>\n</tr>\n'

tempLog.write(formatTable)

for name in statisDic.keys():
    explain = statisDic[name]['explain']
    total = statisDic[name]['total']
    lt300 = statisDic[name]['lt300']
    success = statisDic[name]['successe']
    fail = int(total) - int(success)
    failPer = round(float(success)/float(total),2) * 100

    table = '<tr><td height="30">%(name)s</td><td>%(explain)s</td><td>%(total)d</td><td>%(lt300)d</td>\
    <td>%(success)d</td><td>%(fail)d</td><td>%(failPer)s</td></tr>' %{'name':name,'explain':explain,'total':total,'lt300':lt300,\
    'success':success,'fail':fail,'failPer':failPer,}
    tempLog.write(table)

tempLog.close()
os.system('/home/appSys/smsRebuild/sbin/mnote_analysis_py.sh')
