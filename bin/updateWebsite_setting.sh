# 先备份
~/sbin/smsRebuild_update.sh setting backup

# 删除旧配置
ssh 172.16.200.2 'ls ~/setting.together/setting/WEB-INF/*'
ssh 172.16.200.8 'ls ~/setting.together/setting/WEB-INF/*'
ssh 172.16.200.9 'ls ~/setting.together/setting/WEB-INF/*'
ssh 172.16.200.2 'rm -rf ~/setting.together/setting/WEB-INF/*'
ssh 172.16.200.8 'rm -rf ~/setting.together/setting/WEB-INF/*'
ssh 172.16.200.9 'rm -rf ~/setting.together/setting/WEB-INF/*'

# 开始更新
~/sbin/smsRebuild_update.sh setting update_setting

# 先kill掉相应进程，然后重启相应tomcat，kill过程省略
ssh 172.16.200.2 '~/sbin/tomcat_setting_together.sh restart'
ssh 172.16.200.8 '~/sbin/tomcat_setting_together.sh restart'
ssh 172.16.200.9 '~/sbin/tomcat_setting_together.sh restart'

# 异常处理, 下午已经做了还原点
#~/sbin/smsRebuild_update.sh setting resume 201409181652
#ssh 172.16.200.2 '~/sbin/tomcat_setting_together.sh restart'
#ssh 172.16.200.8 '~/sbin/tomcat_setting_together.sh restart'
#ssh 172.16.200.9 '~/sbin/tomcat_setting_together.sh restart'
