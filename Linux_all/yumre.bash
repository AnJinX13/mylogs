#!/bin/bash
#centos 7.5 yum
#root user
if   [ `whoami` != "root" ];then 	
echo "		++++++++++++++++++++++
		+only root can to run+
		++++++++++++++++++++++"
exit 1

	else 
sleep 1	
		echo "			++++++++++++++++++
			+startting to run+
			++++++++++++++++++"

#O: remove old rpm packages
	if	rpm -qa |grep yum > /dev/null 2>&1
		then 
			rpm -e --nodeps `rpm -qa |grep yum` > /dev/null 2>&1
			echo "remove old packages"
		else
			echo "ready download packages"
	fi


#1: get new prm packages for yum
	cp -a yum.repo /usr/local/src
	cd /usr/local/src
	echo "start downlaoding packages for yum install"
	
wget http://vault.centos.org/7.5.1804/os/x86_64/Packages/yum-3.4.3-158.el7.centos.noarch.rpm  > /dev/null 2>&1
	echo "[====>----------------]20%"
	wget http://vault.centos.org/7.5.1804/os/x86_64/Packages/yum-metadata-parser-1.1.4-10.el7.x86_64.rpm > /dev/null 2>&1
	echo "[=========>-----------]40%"
	wget http://vault.centos.org/7.5.1804/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.31-45.el7.noarch.rpm > /dev/null 2>&1
	echo "[============>--------]50%"
	wget http://vault.centos.org/7.5.1804/os/x86_64/Packages/python-iniparse-0.4-9.el7.noarch.rpm > /dev/null 2>&1
	echo "[================>----]70%"
	wget http://vault.centos.org/7.5.1804/os/x86_64/Packages/python-urlgrabber-3.10-8.el7.noarch.rpm > /dev/null 2>&1
#	wget http://vault.centos.org/7.5.1804/os/Source/SPackages/yum-utils-1.1.31-45.el7.src.rpm > /dev/null 2>&1
	echo "[=====================]100%"

ls 

sleep 2
#2: start executing install packages file
	echo "start executing install packages file "
	rpm -ivh python-iniparse-0.4-9.el7.noarch.rpm  
	rpm -ivh python-urlgrabber-3.10-8.el7.noarch.rpm 
	rpm -ivh yum-metadata-parser-1.1.4-10.el7.x86_64.rpm 
#	rpm -ivh yum-utils-1.1.31-45.el7.src.rpm
	rpm -ivh yum-plugin-fastestmirror-1.1.31-45.el7.noarch.rpm  yum-3.4.3-158.el7.centos.noarch.rpm



#3: update yum soures
#	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
	echo "       #################################
	      #######update your yum soures####
	      #################################"
	cat /home/an/yum.repo > /etc/yum.repo.d/CentOS-Base.repo

	yum clean all && yum makecache 

fi

