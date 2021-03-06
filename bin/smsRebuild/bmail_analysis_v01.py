#!/usr/bin/env python
# -*- coding:UTF-8 -*-

import os,sys,re
import time
logTime = time.strftime('%Y-%m-%d',time.localtime(time.time()-24*60*60))
logName = ['/home/logs/smsmw/172.16.210.52/bmail/monitoring.log.'+logTime,\
        '/home/logs/smsmw/172.16.210.53/bmail/monitoring.log.'+logTime,\
        '/home/logs/smsmw/172.16.210.54/bmail/monitoring.log.'+logTime]
#logName = ['/tmp/bmail_monitoring.log']
setDic =   {'mbox:searchMessages':'总搜索接口',\
        'mbox:getInformation':'酷版资讯分享内容获取',\
        'mailAttach:download':'酷版附件下载',\
        'contact:uploadImage':'用户上传头像（普通）',\
        'contact:uploadAfterCut':'用户裁剪图片上传为头像',\
        'contact:uploadImageFromDisk':'用户从网盘上传头像',\
        'contact:uploadAfterDealImage':'上传base64编码的头像',\
        }
infoDic = {'SearchContacts':'通信录接口','rm SearchMessages':'RM调用接口'}
"""
psDic = {'callPSMainUserInfo':'查询邮箱属性','callPSPersonal':'查询个人信息','callPS1003':'查询配置表','callPS6201':'修改配置表',\
        'callPS7001':'获取邮件到达通知设置项','callPS7003':'用户邮件到达通知明细增加','callPS7004':'用户邮件到达通知明细修改',\
        'callPS7005':'邮件到达通知明细删除接口','callPS6100':'用户登录历史记录查询'}
"""
statisDic = {}
statisDic1 = {}
#statisDic2 = {}

if os.path.isfile('/tmp/bmail_analysis.html'):
    os.remove("/tmp/bmail_analysis.html")

#统计setting接口耗时
for log in logName:
    monitLog = open(log,'r')
    while True:
        lines = monitLog.readlines(5000)
        if not lines:
            break
        for line in lines:
            fields = line.split('|')
            if len(fields) > 12:
                requestTime = fields[8]
                actionUrl = fields[11]
                mergeInfo = fields[12]
                mergeInfoName = fields[11]
                mergeRunTime = fields[7]
                profiles = fields[11]
                profilesName = fields[12]
                psRunTime = fields[7]
                #处理常用setting接口统计
                if re.search(r'RequestTime',requestTime):
                    #interfaceName = actionUrl.split('=')[2]
                    match = re.search(r'(?<=func=)[^&]+',actionUrl)
                    if match:
                        interfaceName = match.group(0)
                        time = int(requestTime.split('=')[1].strip())
                        if interfaceName in setDic.keys():
                            statisDic.setdefault(interfaceName,{'explain':setDic[interfaceName],\
                                    'total':0,'lt50':0,'lt100':0,'lt150':0,'lt200':0,'lt300':0,'lt500':0,'lt1000':0})['total'] += 1
                            if time < 50 :
                                statisDic[interfaceName]['lt50'] += 1
                            elif time >50 and time <= 100:
                                statisDic[interfaceName]['lt100'] += 1
                            elif time >100 and time <= 150:
                                statisDic[interfaceName]['lt150'] += 1
                            elif time >150 and time <= 200:
                                statisDic[interfaceName]['lt200'] += 1
                            elif time >200 and time <= 300:
                                statisDic[interfaceName]['lt300'] += 1
                            elif time >300 and time <= 500:
                                statisDic[interfaceName]['lt500'] += 1
                            elif time >500 and time <= 1000:
                                statisDic[interfaceName]['lt1000'] += 1
                #处理mergeInfo接口统计
            elif re.search(r'RunTime',mergeRunTime):
                interfaceName = mergeInfoName.split('=')[1]
                time = int(mergeRunTime.split('=')[1].strip())
                if interfaceName in infoDic.keys():
                    statisDic1.setdefault(interfaceName,{'explain':infoDic[interfaceName],\
                            'total':0,'lt50':0,'lt100':0,'lt150':0,'lt200':0,'lt300':0,'lt500':0,'lt1000':0})['total'] += 1
                    if time < 50 :
                        statisDic1[interfaceName]['lt50'] += 1
                    elif time >50 and time <= 100:
                        statisDic1[interfaceName]['lt100'] += 1
                    elif time >100 and time <= 150:
                        statisDic1[interfaceName]['lt150'] += 1
                    elif time >150 and time <= 200:
                        statisDic1[interfaceName]['lt200'] += 1
                    elif time >200 and time <= 300:
                        statisDic1[interfaceName]['lt300'] += 1
                    elif time >300 and time <= 500:
                        statisDic1[interfaceName]['lt500'] += 1
                    elif time >500 and time <= 1000:
                        statisDic1[interfaceName]['lt1000'] += 1
                    #处理常用PS接口统计
                    """
           elif re.search(r'ProfilesService',profiles):
               interfaceName = profilesName.split('=')[1]
               time = int(psRunTime.split('=')[1].strip())
               if interfaceName in psDic.keys():
                   statisDic2.setdefault(interfaceName,{'explain':psDic[interfaceName],\
                           'total':0,'lt50':0,'lt100':0,'lt150':0,'lt200':0,'lt300':0,'lt500':0,'lt1000':0})['total'] += 1
                   if time < 50 :
                       statisDic2[interfaceName]['lt50'] += 1
                   elif time >50 and time <= 100:
                       statisDic2[interfaceName]['lt100'] += 1
                   elif time >100 and time <= 150:
                       statisDic2[interfaceName]['lt150'] += 1
                   elif time >150 and time <= 200:
                       statisDic2[interfaceName]['lt200'] += 1
                   elif time >200 and time <= 300:
                       statisDic2[interfaceName]['lt300'] += 1
                   elif time >300 and time <= 500:
                       statisDic2[interfaceName]['lt500'] += 1
                   elif time >500 and time <= 1000:
                       statisDic2[interfaceName]['lt1000'] += 1
                    """
    monitLog.close()

#格式化输出
tempLog = open('/tmp/bmail_analysis.html','a')

"""
formatTable = '<table width="1130" border="1" align="left" cellpadding="0" cellspacing="0">\n\
        <tr>\n<td width="220" height="30">接口名称 </td>\n<td width="200">接口说明</td>\n<td width="80">访问总量</td>\n<td width="80">0~50%</td>\n\
        <td width="80">51~100%</td>\n<td width="80">101~150%</td>\n<td width="80">151~200%</td>\n<td width="80">201~300%</td>\n<td width="80">300~500%</td>\n\
        <td width="80">500~1000%</td>\n<td width="80">&gt;1000%</td>\n</tr>\n'
"""

formatTable = '<table width="1130" border="1" align="left" cellpadding="0" cellspacing="0">\n\
        <tr>\n<td width="220" height="30">接口名称 </td>\n<td width="200">接口说明</td>\n<td width="80">访问总量</td>\n<td width="80">0~50毫秒(%)</td>\n\
        <td width="80">51~100毫秒(%)</td>\n<td width="80">101~150毫秒(%)</td>\n<td width="80">151~200毫秒(%)</td>\n<td width="80">201~300毫秒(%)</td>\n<td width="80">300~500毫秒(%)</td>\n\
        <td width="80">500~1000毫秒(%)</td>\n<td width="80">&gt;1000毫秒(%)</td>\n</tr>\n'

tempLog.write(formatTable)
#处理setting接口
for name in statisDic.keys():
    explain = statisDic[name]['explain']
    total = statisDic[name]['total']
    lt50 = statisDic[name]['lt50']
    lt100 = statisDic[name]['lt100']
    lt150 = statisDic[name]['lt150']
    lt200 = statisDic[name]['lt200']
    lt300 = statisDic[name]['lt300']
    lt500 = statisDic[name]['lt500']
    lt1000 = statisDic[name]['lt1000']
    bfb50 = str(round((float(lt50))/total*100,2))
    bfb100 = str(round((float(lt100))/total*100,2))
    bfb150 = str(round((float(lt150))/total*100,2))
    bfb200 = str(round((float(lt200))/total*100,2))
    bfb300 = str(round((float(lt300))/total*100,2))
    bfb500 = str(round((float(lt500))/total*100,2))
    bfb1000 = str(round((float(lt1000))/total*100,2))
    bfbGt1000 = str(round((float(total - (lt50 + lt100 + lt150 + lt200 + lt300 + lt500 + lt1000)))/total*100,2))

    table = '<tr><td height="30">%(name)s</td><td>%(explain)s</td><td>%(total)d</td>\
            <td>%(bfb50)s</td><td>%(bfb100)s</td><td>%(bfb150)s</td><td>%(bfb200)s</td>\
            <td>%(bfb300)s</td><td>%(bfb500)s</td><td>%(bfb1000)s</td>\
            <td>%(bfbGt1000)s</td></tr>' %{'name':name,'explain':explain,'total':total,'bfb50':bfb50,\
            'bfb100':bfb100,'bfb150':bfb150,'bfb200':bfb200,'bfb300':bfb300,\
            'bfb500':bfb500,'bfb1000':bfb1000,'bfbGt1000':bfbGt1000}
    tempLog.write(table)
#tempLog.write('<tr><td colspan="12">&nbsp;</td></tr>')
#处理info接口
for name in statisDic1.keys():
    explain = statisDic1[name]['explain']
    total = statisDic1[name]['total']
    lt50 = statisDic1[name]['lt50']
    lt100 = statisDic1[name]['lt100']
    lt150 = statisDic1[name]['lt150']
    lt200 = statisDic1[name]['lt200']
    lt300 = statisDic1[name]['lt300']
    lt500 = statisDic1[name]['lt500']
    lt1000 = statisDic1[name]['lt1000']
    bfb50 = str(round((float(lt50))/total*100,2))
    bfb100 = str(round((float(lt100))/total*100,2))
    bfb150 = str(round((float(lt150))/total*100,2))
    bfb200 = str(round((float(lt200))/total*100,2))
    bfb300 = str(round((float(lt300))/total*100,2))
    bfb500 = str(round((float(lt500))/total*100,2))
    bfb1000 = str(round((float(lt1000))/total*100,2))
    bfbGt1000 = str(round((float(total - (lt50 + lt100 + lt150 + lt200 + lt300 + lt500 + lt1000)))/total*100,2))

    table = '<tr><td height="30">%(name)s</td><td>%(explain)s</td><td>%(total)d</td>\
            <td>%(bfb50)s</td><td>%(bfb100)s</td><td>%(bfb150)s</td><td>%(bfb200)s</td>\
            <td>%(bfb300)s</td><td>%(bfb500)s</td><td>%(bfb1000)s</td>\
            <td>%(bfbGt1000)s</td></tr>' %{'name':name,'explain':explain,'total':total,'bfb50':bfb50,\
            'bfb100':bfb100,'bfb150':bfb150,'bfb200':bfb200,'bfb300':bfb300,\
            'bfb500':bfb500,'bfb1000':bfb1000,'bfbGt1000':bfbGt1000}
    tempLog.write(table)
#tempLog.write('<tr><td colspan="12">&nbsp;</td></tr>')
#处理ps接口
#for name in statisDic2.keys():
#    explain = statisDic2[name]['explain']
#    total = statisDic2[name]['total']
#    lt50 = statisDic2[name]['lt50']
#    lt100 = statisDic2[name]['lt100']
#    lt150 = statisDic2[name]['lt150']
#    lt200 = statisDic2[name]['lt200']
#    lt300 = statisDic2[name]['lt300']
#    lt500 = statisDic2[name]['lt500']
#    lt1000 = statisDic2[name]['lt1000']
#    bfb300 = str(round((float(lt50 + lt100 + lt150 + lt200 + lt300))/total*100,2))
#    bfb500 = str(round((float(lt500))/total*100,2))
#    bfb1000 = str(round((float(lt1000))/total*100,2))
#    bfbGt1000 = str(round((float(total - (lt50 + lt100 + lt150 + lt200 + lt300 + lt500 + lt1000)))/total*100,2))
#    
#    table = '<tr><td height="30">%(name)s</td><td>%(explain)s</td><td>%(total)d</td>\
        #    <td>%(lt50)d</td><td>%(lt100)d</td><td>%(lt150)d</td><td>%(lt200)d</td>\
        #    <td>%(lt300)d</td><td>%(bfb300)s</td><td>%(bfb500)s</td><td>%(bfb1000)s</td>\
        #    <td>%(bfbGt1000)s</td></tr>' %{'name':name,'explain':explain,'total':total,'lt50':lt50,\
        #    'lt100':lt100,'lt150':lt150,'lt200':lt200,'lt300':lt300,'lt500':lt500,'lt1000':lt1000,\
        #    'bfb300':bfb300,'bfb500':bfb500,'bfb1000':bfb1000,'bfbGt1000':bfbGt1000}
#    tempLog.write(table)
tempLog.write('</table>')
tempLog.close()
os.system('/home/appSys/smsRebuild/sbin/bmail_analysis_py.sh')
