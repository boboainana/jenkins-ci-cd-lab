# 基于 GitPod 标准工作空间镜像
FROM gitpod/workspace-base:latest

# 安装 Java 11
RUN sudo apt-get update && \
    sudo apt-get install -y openjdk-11-jdk maven && \
    sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java

# 安装 Docker
RUN sudo curl -fsSL https://get.docker.com -o get-docker.sh && \
    sudo sh get-docker.sh && \
    sudo usermod -aG docker gitpod

# 安装 Docker Compose
RUN sudo curl -L "https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose && \
    sudo chmod +x /usr/local/bin/docker-compose

# 安装常用工具
RUN sudo apt-get install -y \
    wget \
    curl \
    git \
    tree \
    jq \
    python3 \
    python3-pip \
    gnupg \
    software-properties-common

# 安装 Node.js（可选，用于前端项目）
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
    sudo apt-get install -y nodejs

# 清理缓存
RUN sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# 创建工具目录
RUN mkdir -p /home/gitpod/tools

# 设置工作目录权限
RUN sudo chown -R gitpod:gitpod /home/gitpod

# 用户切换
USER gitpod
