### 镜像管理命令
###### 下载Docker镜像
```
#默认会连接到docker hub库 也可以使用其他的镜像库如阿里，163或者私有库
docker login <url>
```
![login.jpeg](https://github.com/AnJinX13/mylogs/blob/master/1login.PNG?raw=true)
```
#下载镜像tag默认latest
docker pull <Image:Tag> 
```
![1_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/pull.png?raw=)
```
#查看本地已有镜像
docker iamges
```
![2_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/images.png?raw=true)
```
#搜索镜像
docker search <Image>
```
![3_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/search.png?raw=true)
```
#重命名镜像或标签
docker tag <CurrentImage:CurrentTag> <NewImage:NewTag>
```
![4_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/tag.png?raw=true)
```
#上传本地镜像到远程仓库中
docker push <Image:Tag> 
```
![5_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/push.png?raw=true)
```
#删除本地镜像
docker rmi <Image:Tag>
#如果存在一个镜像多个tag名时，此命令只删除指定标签。若想删除镜像可以直接指定imageID。
```
![6_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/rmi.png?raw=true)
```
#导出镜像成文件
docker save <Image:Tag> -o <FileName>
```
![7_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/save.png?raw=true)
```
#导入镜像到本地仓库中
docker load -i <FileName>
#恢复时如果压缩包的源镜像还在切tag不变，则无法导入
```
![8_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/load.png?raw=true)
```
#使用Dockerfile生成镜像
docker build -t <Image:Tag> <DockerfilePath>
```
![9_jpeg](https://github.com/AnJinX13/pictures/blob/master/management/build.png?raw=true)
```