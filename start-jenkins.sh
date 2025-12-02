#!/bin/bash
# start-jenkins.sh

set -e

echo "========================================"
echo "🚀 启动 Jenkins CI/CD 实验环境"
echo "========================================"

# 检查 Docker 是否运行
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker 服务未运行，请启动 Docker"
    exit 1
fi

# 创建必要的目录
mkdir -p jenkins_data
mkdir -p demo-app

# 检查是否已有 Jenkins 容器在运行
if docker ps | grep -q jenkins-ci-cd; then
    echo "ℹ️  Jenkins 已经在运行"
    echo "   控制台: http://localhost:8080"
    exit 0
fi

# 拉取 Jenkins 镜像
echo "📥 拉取 Jenkins 镜像..."
docker pull jenkins/jenkins:lts-jdk11

# 启动 Jenkins
echo "🚀 启动 Jenkins 容器..."
docker run -d \
  --name jenkins-ci-cd \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v $(pwd)/jenkins_data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/demo-app:/workspace \
  jenkins/jenkins:lts-jdk11

# 等待 Jenkins 启动
echo "⏳ 等待 Jenkins 启动（大约 30 秒）..."
sleep 30

# 获取初始管理员密码
JENKINS_PASSWORD=$(docker exec jenkins-ci-cd cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "admin")

echo ""
echo "✅ Jenkins 启动成功！"
echo "========================================"
echo "🔗 访问地址: http://localhost:8080"
echo "👤 用户名: admin"
echo "🔑 初始密码: $JENKINS_PASSWORD"
echo ""
echo "📋 重要提示："
echo "   1. 首次登录后请立即修改密码"
echo "   2. 点击 '安装推荐的插件'"
echo "   3. 创建第一个管理员用户"
echo "========================================"
echo ""
echo "💡 其他命令："
echo "   stop-jenkins    - 停止 Jenkins"
echo "   restart-jenkins - 重启 Jenkins"
echo "   jenkins-logs    - 查看日志"
