### Docker容器
※容器是用于运行应用的载体，并且容器是基于镜像进行运行的，在运行中数据是相当于在镜像的只读层上在加多了一层可写层，用户可以基于镜像创建一个或多个容器。

###### 容器管理命令
```
#查看容器状态
docker ps 
```
![ps_png](https://yqfile.alicdn.com/71095ae3e4e1cbba63f5740feccfb94455eebc22.jpeg)
```
#查看容器详情
docker inspect <containerID> 
```
![inspect_png](https://yqfile.alicdn.com/d941c8e917d7bd087949d1e74b7283a595f7cfc8.jpeg)
```
#在运行容器中执行命令
docker exec <Command> 
```
![exec1_png](https://github.com/AnJinX13/pictures/blob/master/management/exec1.png?raw=true)
![exec2_png](https://github.com/AnJinX13/pictures/blob/master/management/exec2.png?raw=true)        
※ status must is up 
```
#将容器生成新的镜像
docker commit  <contrainerID> <Image:Tag> 
```
![4_jpeg](https://yqfile.alicdn.com/b2b496b56b7b215f769f6ab1c9af85dd887dd016.jpeg)
```
#复制本地文件系统的文件到容器指定路径
docker cp <srcPath> <destPath> 
```
![5_jpeg](https://yqfile.alicdn.com/8665ca6dd66ae377df931a8c6684e90215f3b7d4.jpeg)
```
#查看容器日志
docker logs <contrainerID> 
```
![6_jpeg](https://yqfile.alicdn.com/34f0d1b197b13c6a1a3cf7d192ad6bd6fb3e8d33.jpeg)
```
#查看容器映射的端口
docker port <contrainerID> 
```
![7_jpeg](https://yqfile.alicdn.com/e07e7d0a3758a1c7747fce1ad73a022871297d86.jpeg)
```
#查看容器运行进程
docker top <contrainerID> 
docker ps [-a] <contrainerID>
```
![8_jpeg](https://yqfile.alicdn.com/58c86b5d9562e2761d1c8c1da7ab3c033f584dc9.jpeg)
![ps_png](https://github.com/AnJinX13/pictures/blob/master/management/ps.jpg?raw=true)
```
#查看容器运行所用资源
docker stats <contrainerID> 
```
![9_jpeg](https://yqfile.alicdn.com/2fe5bf0289ba1ed72da07fd6f065ef4356ea439c.jpeg)
```
#从镜像中创建容器
docker create <Image>
```
![10_jpeg](https://yqfile.alicdn.com/3b1bda261203b26bc2a726ff1ed9bee24e04925c.jpeg)
```
#将已创建容器状态该变
docker {start|stop|restart} <contrainerID> 
#删除状态为已停止的容器
docker rm <contrainerID>
```

###### 运行容器选项参数
```
-i 交互式
-t 分配终端
-e 设置环境变量
-p 映射指定端口到主机指定端口
-P 映射EXPOSE的端口到主机的随机端口
--name 指定容器名称
-h 设置容器主机名
-ip 自定容器IP
-network 指定网络模式
-mount 挂载文件系统至容器
-v 挂载卷至容器
-restart 设置退出容器时是否重启
-l 设置容器元数据标签
-m 内存限制
-c cpu限制
-u 指定运行的用户
-w 指定工作目录
```