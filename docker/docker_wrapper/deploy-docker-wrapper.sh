#!/bin/bash
# deploy-docker-wrapper-simple.sh

echo "=== Docker Wrapper  部署（简化版）==="

# 1. 创建日志目录
sudo mkdir -p /var/log/docker-wrapper 
sudo touch /var/log/docker-wrapper/docker-wrapper.log
sudo chmod 666 /var/log/docker-wrapper/docker-wrapper.log

# 2. 备份原 docker
sudo mv /usr/local/bin/docker /usr/local/bin/docker.orig 2>/dev/null || true

# 3. 安装简化版 wrapper
sudo cp docker-wrapper.sh /usr/local/bin/docker
sudo chmod +x /usr/local/bin/docker

# 4. 初始化挂载配置
cat > /etc/docker-wrapper/allowed_mounts.conf << 'EOF'
# Docker Wrapper Allowed Mounts
# 管理员通过 sudo docker --add-mount 添加路径
EOF

echo "=== 部署完成 ==="
echo "功能测试："
echo "docker --list-mounts           # 默认路径"
echo "docker images                  # 所有镜像"
echo "docker run -it alpine ls       # 自动加label"
echo "docker ps                      # 只显示自己的"
echo "tail -f /var/log/docker-wrapper/docker-wrapper.log  # 查看日志"
