### Docker修改默认pull文件位置
that first.     
老样子，emm 没有链接 hh.
#### 1.简易法
直接将其他位置软连接到docker下替代实际使用的文件位置.
###### A.先查看一下Docker信息
```
an@1:~$ sudo docker info 
```
###### B.停止Docker服务
```
an@1:~$ sudo service docker stop
```
###### C.迁移Docker路径
```
an@1:~$ cd /var/lib/
an@1:~$ mv docker /devdata/docker `这是新挂载磁盘的位置`
```
###### D.建立软连接
```
an@1:~$ ln -s /decdata/docker docker
```
###### E.启动docker服务
```
an@1:~$ sudo service docker start
```
###### F.再次查看docker信息
```
an@1:~$ sudo docker info 
```
查看信息是否完整一致，确认是否成功.
这样简便快速，缺点是当ln失效docker就会同样失效。
#### 2.切实法
###### A.备份doker下的镜像images
```
an@1:~$ sodu docker save -o backname.tar imagename
an@1:~$ ls
```
###### B.停止docker服务
```
an@1:~$ sudo systemtcl stop docker
```
###### C.指定新的存储位置
```
an@1:~$ mkdir  'new directory' #新的存储位置
an@1:~$ touch `new configfile`#配置文件名应该可以随意。
an@1:~$ vim /etc/systemd/system/docker.service.d/docker-overlay.conf#添加新的文件路径。
    
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd --graph="/home/docker" --storage-driver=overlay
    #将/home/docker 替换为新建的目录路径`new directory`
```
###### D.重启docker服务
```
an@1:~$ sudo systemtcl start docker
#有时docker的守护进程也停掉的话也需要启动
#sudo systemctl {start|stop|restart} docker
#sudo systemctl daemon-{start|stop|reload}
```
###### E.回复备份镜像
```
an@1:~$ sudo load -i `backname.tar`
```
###### F.确认更改生效
```
an@1:~$ sudo rm -rf /var/lib/docker
an@1:~$ sudo docker images
an@1:~$ sudo pull ubuntu 
#删去原来的存储目录，查看image并下载新的镜像验证。