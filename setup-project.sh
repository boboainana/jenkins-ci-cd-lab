#!/bin/bash
# setup-project.sh

set -e

echo "========================================"
echo "📦 设置示例 Java 项目"
echo "========================================"

PROJECT_DIR="demo-app"

if [ -d "$PROJECT_DIR" ]; then
    echo "ℹ️  项目已存在，跳过创建"
else
    # 创建项目目录
    mkdir -p $PROJECT_DIR
    cd $PROJECT_DIR

    # 创建项目结构
    echo "📁 创建项目结构..."
    mkdir -p src/main/java/com/example/demo
    mkdir -p src/test/java/com/example/demo
    mkdir -p src/main/resources

    # 创建 pom.xml
    cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>demo-app</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    
    <name>Jenkins CI/CD Demo Application</name>
    
    <properties>
        <java.version>11</java.version>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>2.7.0</version>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <version>2.7.0</version>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.13.2</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>2.7.0</version>
            </plugin>
            
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.0.0-M5</version>
            </plugin>
        </plugins>
    </build>
</project>
EOF

    # 创建主应用类
    cat > src/main/java/com/example/demo/DemoApplication.java << 'EOF'
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DemoApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
    
    @GetMapping("/")
    public String home() {
        return "Welcome to Jenkins CI/CD Demo!";
    }
    
    @GetMapping("/health")
    public String health() {
        return "{\"status\": \"UP\"}";
    }
}
EOF

    # 创建测试类
    cat > src/test/java/com/example/demo/DemoApplicationTest.java << 'EOF'
package com.example.demo;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@RunWith(SpringRunner.class)
@WebMvcTest
public class DemoApplicationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    public void testHomeEndpoint() throws Exception {
        mockMvc.perform(get("/"))
               .andExpect(status().isOk())
               .andExpect(content().string("Welcome to Jenkins CI/CD Demo!"));
    }
    
    @Test
    public void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/health"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.status").value("UP"));
    }
}
EOF

    # 创建配置文件
    cat > src/main/resources/application.properties << 'EOF'
server.port=3000
spring.application.name=demo-app
EOF

    # 创建 Dockerfile
    cat > Dockerfile << 'EOF'
FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 3000
CMD ["java", "-jar", "app.jar"]
EOF

    # 创建 Jenkinsfile
    cat > Jenkinsfile << 'EOF'
pipeline {
    agent any
    
    tools {
        maven 'Maven'
        jdk 'Java'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/yourusername/demo-app.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
                archiveArtifacts 'target/*.jar'
            }
        }
        
        stage('Docker Build') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh 'docker build -t demo-app:latest .'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed!'
        }
    }
}
EOF

    # 创建 README
    cat > README.md << 'EOF'
# Jenkins CI/CD Demo Application

这是一个用于学习 Jenkins CI/CD 流水线的示例 Java 应用程序。

## 项目结构
