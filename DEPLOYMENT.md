# PairDrop ARM32 部署指南

本指南帮助你在 ARM32 设备（如玩客云）上快速部署 PairDrop。

## 📋 前置要求

1. **ARM32 设备**：玩客云、树莓派等支持 ARMv7 架构的设备
2. **操作系统**：已安装 Linux 系统（如 Armbian、Debian 等）
3. **Docker 环境**：
   - Docker Engine 20.10+
   - Docker Compose 1.29+

### 安装 Docker（如未安装）

```bash
# 使用官方安装脚本（适用于大多数 Linux 发行版）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将当前用户添加到 docker 组（避免每次使用 sudo）
sudo usermod -aG docker $USER

# 重新登录或执行以下命令使组权限生效
newgrp docker

# 验证安装
docker --version
docker-compose --version
```

## 🚀 快速部署

### 1. 下载配置文件

```bash
# 创建项目目录
mkdir -p ~/pairdrop && cd ~/pairdrop

# 下载 docker-compose.yml
# 方式一：从 GitHub 仓库下载
wget https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/PairDrop-arm32/main/docker-compose.yml

# 方式二：手动创建（复制下方内容）
nano docker-compose.yml
```

### 2. 修改配置

编辑 `docker-compose.yml`，**必须**将 `YOUR_GITHUB_USERNAME` 替换为你的 GitHub 用户名：

```yaml
image: ghcr.io/YOUR_GITHUB_USERNAME/pairdrop:latest
```

例如，如果你的 GitHub 用户名是 `schlagmichdoch`，则改为：

```yaml
image: ghcr.io/schlagmichdoch/pairdrop:latest
```

### 3. 启动服务

```bash
# 拉取镜像并启动容器
docker-compose up -d

# 查看运行状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 4. 访问服务

在浏览器中访问：`http://设备IP:3000`

例如，如果你的玩客云 IP 是 `192.168.1.100`，则访问：`http://192.168.1.100:3000`

## ⚙️ 环境变量配置

在 `docker-compose.yml` 中可配置以下环境变量：

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `WS_FALLBACK` | `false` | WebRTC 不可用时是否启用 WebSocket 降级 |
| `RATE_LIMIT` | `false` | 是否限制客户端请求速率（5分钟1000次） |
| `RTC_CONFIG` | `false` | 自定义 STUN/TURN 服务器配置文件路径 |
| `DEBUG_MODE` | `false` | 是否启用调试模式 |
| `TZ` | `Asia/Shanghai` | 时区设置 |

### 公网部署建议

如果你的设备暴露在公网上，建议启用速率限制：

```yaml
environment:
  - RATE_LIMIT=true
```

## 🔧 常用命令

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新镜像到最新版本
docker-compose pull
docker-compose up -d

# 查看容器日志
docker-compose logs -f pairdrop

# 查看容器资源占用
docker stats pairdrop

# 进入容器内部（调试用）
docker-compose exec pairdrop sh
```

## 🐛 常见问题

### 1. 镜像拉取失败

**问题**：`Error response from daemon: manifest unknown`

**解决方案**：
- 确认已将 `YOUR_GITHUB_USERNAME` 替换为正确的 GitHub 用户名
- 确认 GitHub Actions 已成功构建并推送镜像到 GHCR
- 检查镜像是否为公开访问（在 GitHub 仓库 Packages 设置中）

### 2. 端口冲突

**问题**：`Bind for 0.0.0.0:3000 failed: port is already allocated`

**解决方案**：修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8080:3000"  # 将主机端口改为 8080 或其他未占用端口
```

### 3. 容器无法启动

**问题**：容器状态显示 `Restarting` 或 `Exited`

**解决方案**：
```bash
# 查看详细日志
docker-compose logs pairdrop

# 检查容器健康状态
docker inspect pairdrop | grep -A 10 Health
```

### 4. 设备间无法连接

**问题**：设备在同一局域网但无法互相发现

**解决方案**：
- 确认设备在同一子网内
- 检查防火墙是否阻止了 WebRTC 连接
- 尝试启用 WebSocket 降级：`WS_FALLBACK=true`

### 5. ARM32 设备性能不足

**问题**：玩客云等低性能设备运行缓慢

**优化建议**：
- PairDrop 是轻量级应用，正常情况下 ARM32 设备完全够用
- 如遇性能问题，检查是否有其他服务占用资源
- 考虑关闭调试模式：`DEBUG_MODE=false`

## 📊 验证部署

### 检查镜像架构

```bash
# 查看已拉取的镜像架构
docker image inspect ghcr.io/YOUR_GITHUB_USERNAME/pairdrop:latest | grep Architecture

# 应显示：linux/arm/v7
```

### 功能测试

1. **本地测试**：在同一设备上打开两个浏览器标签页
2. **局域网测试**：在同一 Wi-Fi 下的两台设备上访问
3. **文件传输测试**：发送图片、文档等文件
4. **配对测试**：使用 6 位数字码配对设备

## 🔄 更新策略

### 自动更新（推荐）

使用 Watchtower 自动更新容器：

```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --interval 86400 \
  pairdrop
```

### 手动更新

```bash
cd ~/pairdrop
docker-compose pull
docker-compose up -d
```

## 📝 数据持久化

如需持久化配置或日志，取消 `docker-compose.yml` 中的 volumes 注释：

```yaml
volumes:
  - ./pairdrop-data:/app/data
```

## 🆘 获取帮助

- **GitHub Issues**：https://github.com/YOUR_GITHUB_USERNAME/PairDrop-arm32/issues
- **原项目文档**：https://github.com/schlagmichdoch/PairDrop
- **Docker 日志**：`docker-compose logs -f`

## 📜 许可证

本项目基于 [PairDrop](https://github.com/schlagmichdoch/PairDrop) 项目，遵循其原有许可证。
