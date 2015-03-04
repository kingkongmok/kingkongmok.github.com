#!/usr/bin/env python
# -*- coding:UTF-8 -*-

import os,sys,re
import time
logTime = time.strftime('%Y-%m-%d',time.localtime(time.time()-24*60*60))
logName = ['/home/logs/smsmw/172.16.210.52/calendar/monitor.log.'+logTime,\
           '/home/logs/smsmw/172.16.210.53/calendar/monitor.log.'+logTime,\
           '/home/logs/smsmw/172.16.210.54/calendar/monitor.log.'+logTime]
#logName = ['/tmp/monitor.log']

setDic = {'calendar:addLabel':'添加日历','calendar:updateLabel':'更新日历','calendar:deleteLabel':'删除日历',\
          'calendar:getLabelById':'根据日历ID查询日历','calendar:subscribeLabel':'订阅公共日历','calendar:cancelSubscribeLabel':'取消订阅公共日历',\
          'calendar:getLabels':'查询用户日历列表','calendar:listTopLabels':'查询前十个公共日历','calendar:getCalendarListView':' 查询活动列表（时间轴）',\
          'calendar:getCalendarView':'查询用户活动列表','calendar:getCalendar':'查询用户某个活动','calendar:addCalendar':'添加活动',\
          'calendar:updateCalendar':'更新活动','calendar:deleteCalendar':'取消活动','api:getCalendarListView':'运营-查询活动列表视图',\
          'api:addCalendar':'运营-添加活动','api:updateCalendar':'运营-更新活动','api:getCalendar':'运营-查询某个活动',\
          'api:deleteCalendar':'运营-删除活动','api:subscribeLabel':'运营-订阅公共日历',\
          'calendar:searchPublicLabel':'搜索公共日历','calendar:getPublishedLabelByOper':'查询单个公共日历的详情（运营）','api:publishLabelByOper':'发布公共日历',\
          'api:updatePublishedLabelByOper':'修改公共日历','calendar:copyCalendar':'复制活动','calendar:getCalendarList':'查询活动列表（时间轴）',\
          'calendar:setCalendarRemind':'设置自定义提醒','calendar:shareCalendar':'活动分享接口','calendar:getCalendarsByLabel':'通过labelID获取所有活动详情',\
          'calendar:getHuangliData':'黄历查询接口','calendar:getMessageCount':'未读消息数量','calendar:getMessageList':'得到消息列表',\
          'calendar:getMessageById':'单个消息详情','calendar:delMessage':'删除消息','calendar:getCalendarView':'查询用户活动视图',\
        'calendar:addGroupLabel':'创建群组日历',\
        'calendar:updateGroupLabel':'更新群日历',\
        'calendar:processShareLabelInfo':'对日历共享请求处理',\
        'api:batchAddLabelShare':'批量添加日历共享',\
        'api:batchDeleteLabelShare':'批量删除日历共享',\
        'calendar:cancelLabelShare':'取消日历共享',\
        'calendar:setLabelUpdateNotify':'被共享者设置活动变更通知方式',\
        'calendar:setSubLabelUpdateNotify':'订阅者设置活动变更通知方式',\
        'calendar:deleteCalendar':'删除（取消）活动',\
        'calendar:batchAddCalendar':'批量创建活动',\
        'calendar:copyCalendar':'复制活动',\
        'calendar:getCalendarListViewByInterval':'活动列表查询(SDK)',\
        'calendar:getCalendarsByLabelId':'通过日历ID获取活动列表（SDK）',\
        'calendar:setCalendarRemind':'设置自定义提醒时间',\
        'calendar:smsUpdateInviteStatus':'短信回复指令接受或者拒绝邀请',\
        'calendar:updateInviteStatus':'对活动邀请请求处理',\
        'calendar:cancelInvitedInfo':'取消邀请关系',\
        'calendar:addMailCalendar':'创建任务式邮件活动',\
        'calendar:updateMailCalendar':'更新任务式邮件活动',\
        'calendar:delMailCalendar':'删除任务式邮件活动',\
        'calendar:getMailCalendar':'任务式邮件活动查询',\
        'calendar:cancelMailCalendars':'批量取消任务提醒',\
        'calendar:initCalendar':'初始化接口',\
        'calendar:addBlackWhiteItem':'添加黑白名单',\
        'calendar:delBlackWhiteItem':'删除黑白名单',\
        'calendar:getBlackWhiteItem':'查询黑白名单项',\
        'calendar:getBlackWhiteList':'查询黑白名单列表',\
        'calendar:syncAddCalendar':'同步添加活动---ActiveSync',\
        'calendar:syncUpdateCalendar':'同步更新活动---ActiveSync',\
        'calendar:syncDelCalendar':'同步删除活动---ActiveSync',\
        'calendar:syncGetCalendars':'同步时间段内变更的活动—ActiveSync',\
        'calendar:addLabelType':'添加日历分类（运营）',\
        'calendar:deleteLabelType':'删除日历分类（运营）',\
        'calendar:updateLabelType':'更新日历分类（运营）',\
        'calendar:getAllLabelTypes':'查询日历分类列表（运营）',\
        'calendar:getLabelsByType':'通过日历分类分页查询日历（运营）',\
        'calendar:publishLabelByOper':'发布公共日历（运营）',\
        'calendar:updatePublishedLabelByOper':'修改发布了的公共日历（运营）',\
        'calendar:searchOperationLabel':'查询公共日历列表（运营）',\
        'calendar:getPublishedLabelByOper':'查询单个公共日历的详情（运营）',
          }

#infoDic = {'mealInfo':'套餐信息','mailInfo':'邮箱属性','whoAddMe':'谁加了我','dynamicInfo':'动态信息',\
#           'checkinInfo':'签到信息','personalInfo':'个人信息','weatherInfo':'天气预报','birthdayInfo':'好友生日提醒'}
#psDic = {'callPSMainUserInfo':'查询邮箱属性','callPSPersonal':'查询个人信息','callPS1003':'查询配置表','callPS6201':'修改配置表',\
#         'callPS7001':'获取邮件到达通知设置项','callPS7003':'用户邮件到达通知明细增加','callPS7004':'用户邮件到达通知明细修改',\
#         'callPS7005':'邮件到达通知明细删除接口','callPS6100':'用户登录历史记录查询'}
statisDic = {}
#statisDic1 = {}
#statisDic2 = {}

if os.path.isfile('/tmp/calendar_analysis.html'):
    os.remove("/tmp/calendar_analysis.html")

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
                try:
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
                except Exception:
                    print line
                    continue
    monitLog.close()

#格式化输出
tempLog = open('/tmp/calendar_analysis.html','a')

#formatTable = '<table width="1130" border="1" align="left" cellpadding="0" cellspacing="0">\n\
#<tr>\n<td width="220" height="30">接口名称 </td>\n<td width="200">接口说明</td>\n<td width="80">访问总量</td>\n<td width="80">0~50%</td>\n\
#<td width="80">51~100%</td>\n<td width="80">101~150%</td>\n<td width="80">151~200%</td>\n<td width="80">201~300%</td>\n<td width="80">300~500%</td>\n\
#<td width="80">500~1000%</td>\n<td width="80">&gt;1000%</td>\n</tr>\n'

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
##处理info接口
#for name in statisDic1.keys():
#    explain = statisDic1[name]['explain']
#    total = statisDic1[name]['total']
#    lt50 = statisDic1[name]['lt50']
#    lt100 = statisDic1[name]['lt100']
#    lt150 = statisDic1[name]['lt150']
#    lt200 = statisDic1[name]['lt200']
#    lt300 = statisDic1[name]['lt300']
#    lt500 = statisDic1[name]['lt500']
#    lt1000 = statisDic1[name]['lt1000']
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
#tempLog.write('<tr><td colspan="12">&nbsp;</td></tr>')
##处理ps接口
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
os.system('/home/appSys/smsRebuild/sbin/calendar_analysis_py.sh')
