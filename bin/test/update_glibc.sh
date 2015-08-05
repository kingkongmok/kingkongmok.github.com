#!/bin/bash

sys_ver=`lsb_release -r | awk '{print $2}' | cut -c1`

function dl_5()
{
  echo "### Starting download yum repos file from mirror.163.com for redhat 5."
  wget http://mirrors.163.com/.help/CentOS5-Base-163.repo  -O /etc/yum.repos.d/CentOS-Base5-163.repo
  sed  -i 's/$releasever/5/g' /etc/yum.repos.d/CentOS-Base5-163.repo
}

function dl_6()
{
  echo "### Starting download yum repos file from mirror.163.com for redhat 6."
  wget http://mirrors.163.com/.help/CentOS6-Base-163.repo  -O /etc/yum.repos.d/CentOS-Base6-163.repo
  sed  -i 's/$releasever/6/g' /etc/yum.repos.d/CentOS-Base6-163.repo
}


if [ `whoami` != 'root' ];then
  echo "Please run as root user"
  exit 1
fi

if [[ $sys_ver -eq 5 ]];then
  dl_5
elif [[ $sys_ver -eq '6' ]]; then
  dl_6
else
  echo 'Your system is NOT RHEL5/6. NO need to do anything.'
  exit 0
fi

echo "### Start to run yum clean all"
yum clean all

echo "### Start to run yum makecache"
yum makecache

#echo "### Start to run yum install glibc*"
#yum -y update glibc*

# rm -f $0 && echo "### File $0 have been deleted."