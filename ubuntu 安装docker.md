##               ubantu安装Docker.
>that first.        
>老样子，附上先鉴链接
https://docs.docker.com/install/ 官网安装手册
https://yeasy.gitbooks.io/docker_practice/content/install/ubuntu.html Git安装经验

#### 准备工作

###### 系统要求.     
>Docker CE 支持以下版本的 Ubuntu 操作系统：  
Bionic 18.04 (LTS)      
Xenial 16.04 (LTS)  
Docker CE 可以安装在 64 位的 x86 平台或 ARM 平台上。Ubuntu发行版中，LTS（Long-Term-Support）长期支持版本，会获得 5 年的升级维护支持，这样的版本会更稳定，因此在生产环境中推荐使用 LTS 版本。     

###### 卸载旧版本      
旧版本的 Docker 称为 docker 或者 docker-engine，使用以下命令卸载旧版本：

```
an@1:~$ sudo apt-get remove docker \
             docker-engine \
             docker.io
```


#### 使用APT安装.
>※：请勿在未更新docker的apt源就apt下载安装
  
由于apt源使用HTTPS以确保软件下载过程中的安全,内容不被篡改。所以我们先下载HTTPS传输的软件包和CA证书。

```
an@1:~$ sudo apt-get update 
an@1:~$ sudo apt-get install \
             apt-transprot-https \
             ca-certificates \
             curl \
             software-properties-common
```

因为国内网络原因，建议不使用官方的apt源下载，修改为[国内源](https://blog.csdn.net/xiangxianghehe/article/details/80112149)。     
同时，为了确认下载软件包的合法性，需要添加软件源的`GPG`秘钥。
```
an@1:~$ curl -fsSL hhtps://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -      

# 官方源
# $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
然后，需要向source.list中添加docker软件源
```
an@1:~$ sudo add-apt-repository \
    "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu \
    $(lsb_release -cs) \
    stable"     


#官方源
# an@1:~$ sudo add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"  
    
```
以上添加了稳定版本的docker CE APT镜像源，如果需要测试或者每日构建版本的docker CE 可以将`stable` 修改为`test`或者`nightly`。
### 安装Docker CE
更新`apt`软件包缓存，并安装`docker-ce`：
```
an@1:~$ sudo apt-get update

an@1:~$ sudo apt-get install docker-ce
```
### 启动docker CE
```
an@1:~$ sudo systemctl enable docker
an@1:~$ sudo systemctl start docker
```
### 创建docker用户及组
默认情况下，`docker`命令会使用[Unix socket](https://en.wikipedia.org/wiki/Unix_domain_socket)与Docker引擎通讯。而只有`root`用户和`docker`组的用户可以访问Docker引擎的Unix套接。      
所以我们需要将用户加入`docker`组。
```
an@1:~$ sudo groupadd docker

an@1:~$ sudo usermod -aG docker $USER
```
退出当前终端并重新登录，进行测试。
### 测试Docker安装是否成功
```
an@1:~$ docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
d1725b59e92d: Pull complete
Digest: sha256:0add3ace90ecb4adbf7777e9aacf18357296e799f81cabc9fde470971e499788
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
若正常输出以上信息，则安装成功。
### 镜像加速
如果在使用的过程中拉取Docker镜像的速度过慢可以配置[docker国内镜像加速](https://yeasy.gitbooks.io/docker_practice/content/install/mirror.html)。
### 脚本自动安装
在Docker官网有方便测试和开发环境中快速安装的安装脚本，可以直接使用：
```
an@1:~$ curl -fsSL get.docker.com -o get-docker.sh
an@1:~$ sudo sh get-docker.sh --mirror Aliyun
```
执行这个命令后，脚本就会自动的将一切准备工作做好，并且把Docker CE的`Edge`版本安装在系统中。










