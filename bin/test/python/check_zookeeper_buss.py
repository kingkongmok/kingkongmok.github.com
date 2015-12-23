#!/usr/bin/env python
# -*- coding: utf-8 -*- 

######################################
# 本脚本对zookeeper 进行如下测试：
# 1. 写x次
# 2. 读x次
# 3. 删x次
#
# 报警逻辑：
# 1. 如果测试不能完成时
# 2. 如果测试完成得太慢，耗时大于阀值时
#
######################################

import socket
socket.setdefaulttimeout(1)

from datetime import datetime

from kazoo.client import KazooClient

import sys
reload(sys)
sys.setdefaultencoding('utf8') 

import logging
import logging.handlers
import os
import time

from sending_email import send_mail
mailto_list = [
        "user@mail.com" ,
              ]

# 进行读写删测试的次数
checkpoint_count = 500

# 每个测试耗时时长的阀值(单位：秒)，大于则触发报警邮件
each_test_cost_time_limit = 3.0

# zookeeper 测试使用的路径
path = '/test_yunwei/'

# 检测对象列表
servers_wait_4_check = (
        (u'zookeeper服务-1/3', '192.168.1.1:12345'),
        (u'zookeeper服务-2/3', '192.168.1.2:12345'),
        (u'zookeeper服务-3/3', '192.168.1.3:12345'),
)


# 计时函数
def exe_time(func):
    def newFunc(*args, **args2):
        t0 = time.time()
        back = func(*args, **args2)
        taken_time = time.time() - t0
        print "消耗时间：@ %.3fs taken for {%s}" % (taken_time, func.__name__)
        return dict({func.__name__ + "_cost_time" : round(taken_time,3)} )
    return newFunc


# 执行3类检测
def do_check_zookeeper(server_name, server_addr):

    @exe_time
    def do_check_create():
        zk.ensure_path(path + server_addr )
        for i in range(1,checkpoint_count):
            zk.create(path + server_addr + "/" + str(i), str(i) ,\
                    ephemeral=True )

    @exe_time
    def do_check_read():
        children = zk.get_children(path + server_addr )
        for child in children:
            data, stat = zk.get(path + server_addr + "/" + child )
        
    @exe_time
    def do_check_delete():
        children = zk.get_children(path + server_addr )
        for child in children:
            zk.delete(path + server_addr + "/" + child )

    try:
        zk = KazooClient(hosts = server_addr, timeout = 2, connection_retry = \
                1, logger = logger)
        zk.start()

        # 合并3个检测的结果到1个字典中
        test_result = {}
        test_result = dict(test_result, **do_check_create() )
        test_result = dict(test_result, **do_check_read()   )
        test_result = dict(test_result, **do_check_delete() )

    # 当检测出现异常时, return = 1，正常的 return = 0
    except Exception,ex:
        return dict({'item': server_name, 'host': server_addr, 'return': 1, \
            'data': dict({ 'msg': ex })  })
        
    # 当检测正常时
    else:
        return dict({'item': server_name, 'host': server_addr, 'return': 0, \
            'data': test_result} )

    finally:
        zk.stop()



if __name__ == '__main__':

    LOG_FILE = '/tmp/check_zookeeper_buss.log'  
  
    handler = logging.handlers.RotatingFileHandler(LOG_FILE, maxBytes = \
            200*1024*1024 ) # 实例化handler   
    fmt = '%(asctime)s [%(levelname)s] %(filename)s:%(lineno)s %(message)s'  
  
    formatter = logging.Formatter(fmt)   # 实例化formatter  
    handler.setFormatter(formatter)      # 为handler添加formatter  
  
    logger = logging.getLogger('tst')    # 获取名为tst的logger  
    logger.addHandler(handler)           # 为logger添加handler  
    logger.setLevel(logging.DEBUG)  

    result_total = []
    for server in servers_wait_4_check:
        server_name = server[0]
        server_addr = server[1]
        
        print ''
        print "Checking: ",  server_name, server_addr 
        r = do_check_zookeeper(server_name, server_addr)
        result_total.append(r)
        logger.info(r)


    print ''
    print '检测发现的异常情况：'

    # 记录发送邮件的内容
    mail_content = []

    for each_result in result_total:

        if each_result['return'] != 0:
            msg = '[ERROR] %s %s 不能完成检查，出错信息：%s。' % \
            (each_result['item'], each_result['host'],
                    each_result['data']['msg'] )
            print msg
            logger.error(msg)
            mail_content.append('<p>' + msg + '</p>')

        if each_result['return'] == 0:
            for k , v in each_result['data'].iteritems():
                if v > each_test_cost_time_limit:
                    msg = '[ERROR] %s %s %s 检查耗时 > %s 秒，达%s 秒 。' % \
                    (each_result['item'], each_result['host'], k,
                            each_test_cost_time_limit, v  ) 
                    print msg
                    logger.error(msg)
                    mail_content.append('<p>' + msg + '</p>')

    # # 判断是否需要发报警邮件
    # if len(mail_content):
    #     if send_mail(mailto_list, 'zookeeper 拔测出错(%s)' % len(mail_content), \
    #             ' '.join(mail_content) ):
    #         print 'Sending email success.'
    #         logger.info('Sending email success.')
    #     else:
    #         print 'Sending email fail.'  
    #         logger.error('Sending email fail.')
