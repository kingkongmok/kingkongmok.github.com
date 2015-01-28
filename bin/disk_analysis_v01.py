#!/usr/bin/env python
# -*- coding:UTF-8 -*-

import os,sys,re
import time
logTime = time.strftime('%Y-%m-%d',time.localtime(time.time()-24*60*60))
logName = ['/home/logs/smsmw/172.16.210.52/diskmw/diskMonitor.log.'+logTime,'/home/logs/smsmw/172.16.210.53/diskmw/diskMonitor.log.'+logTime,\
		  '/home/logs/smsmw/172.16.210.54/diskmw/diskMonitor.log.'+logTime]
#logName = ['/home/logs/smsmw/172.16.210.52/diskmw/diskMonitor.log.'+logTime]

setDic = {'getWholeCatalog':'获取整个目录结构信息','getDisk':'查询文件和子目录信息','creatCatalog':'创建彩云子目录',\
		  'copyContentCatalog':'复制内容目录','updateCatalogInfo':'用户修改彩云目录名称','moveContentCatalog':'移动内容目录',\
		  'mgtVirDirInfo':'管理虚拟目录信息','qryCtnCtlgCount':'查询用户彩云文件和目录总数','getDiskInfo':'获取彩云容量信息',\
		  'getContentInfo':'查询内容信息','delCatalogContent':'删除用户网盘内的内容和目录',\
	      'updateContentInfo':'修改内容信息','downloadRequest':'下载','downloadZipPkgReq':'打包下载',\
		  'getOutLink':'获取外链','delOutLink':'删除文件外链','dlFromOutLink':'下载外链','simpleSearch':'搜索',\
		  'inviteShare':'邀请共享','cancelShare':'取消共享','getShareList':'浏览发送共享和接收共享列表','getShareInfo':'获取共享信息',\
		  'leaveShare':'退出共享','replyShare':'接收共享','webUploadFile':'web上传','pcUploadFile':'PC文件上传请求方法',\
		  'SyncUploadTaskInfo':'断点续传','uploadFile':'内部上传','directoryFileList':'获取指定文件夹下的子文件夹',\
		  'getDirectorys':'获取所有文件夹信息','packageDownloadUrl':'分布式获取打包下载url','preUpload':'分布式预上传服务',\
          'applyAdditionalSize':'容量调整','manageAccount':'注册'}

infoDic = {'disk:init':'初始化接口','disk:fileList':'文件列表接口','disk:getDirectorys':'获取所有文件夹接口',\
		   'disk:delete':'删除接口','disk:createDirectory':'创建文件夹接口','disk:move':'移动接口',\
		   'disk:download':'获取下载URL接口','disk:fastUpload':'html5上传接口','disk:resumeUpload':'断点续传接口信息',\
		   'disk:normalUpload':'获取普通上传URL接口','disk:search':'搜索接口','disk:thumbnails':'批量获取缩略图接口',\
		   'disk:attachUpload':'附件存网盘接口','disk:setCover':'设置相册封面接口','disk:share':'共享接口',\
		   'disk:friendShareList':'好友共享接口','disk:myShareList':'我的共享接口','disk:cancelShare':'取消共享接口',\
		   'disk:delShare':'删除共享接口','disk:shareCopyTo':'好友共享文件存网盘接口','disk:rename':'重命名接口',\
           'disk:backupBillMail':'备份帐单至彩云对内接口'}

statisDic = {}
statisDic1 = {}

if os.path.isfile('/tmp/disk_analysis.html'):
	os.remove("/tmp/disk_analysis.html")

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
					requestTime = fields[7]
					actionUrl = fields[11]
					diskTime = fields[8]
					mergeInfo = fields[12]
					mergeInfoName = fields[11]
					mergeRunTime = fields[7]
					profiles = fields[11]
					profilesName = fields[12]
					psRunTime = fields[7]
					#
					if re.search(r'RunTime',requestTime):
						interfaceName = actionUrl.split('=')[1]
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
			#
			elif re.search(r'RequestTime',diskTime):
				#interfaceName = actionUrl.split('=')[2]
				match = re.search(r'(?<=func=)[^&]+',actionUrl)
				if match:
						interfaceName = match.group(0)
						time = int(diskTime.split('=')[1].strip())
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
	monitLog.close()

#格式化输出
tempLog = open('/tmp/disk_analysis.html','a')

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
tempLog.write('<tr><td colspan="12">&nbsp;</td></tr>')
##
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
tempLog.write('</table>')
tempLog.close()
os.system('/home/appSys/smsRebuild/sbin/disk_analysis_py.sh')
