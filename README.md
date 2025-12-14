<div align="center">
  <h1>🚀 PairDrop ARM32 版</h1>
  <p><strong>局域网文件传输神器 · 玩客云/树莓派专用</strong></p>
  <p>像苹果"隔空投送"一样，在手机、电脑、平板之间秒传文件 📱💻📷</p>
</div>

---

## 💡 这是什么？

**PairDrop** 是一个超简单的局域网文件传输工具，就像苹果的"隔空投送"（AirDrop），但它：

- ✅ **跨平台**：安卓、苹果、Windows、Mac 全支持
- ✅ **无需安装 App**：打开浏览器就能用
- ✅ **局域网直传**：文件不经过服务器，速度飞快
- ✅ **完全免费**：开源项目，无广告无限制

**本项目特色**：专为 **玩客云、树莓派** 等 ARM32 设备优化，一键部署，装好就能用！🎉

---

## 🚀 极速部署（复制粘贴即可）

> **适用设备**：玩客云、树莓派、斐讯 N1 等 ARM32/ARM64 设备  
> **前提条件**：已安装 Docker 和 Docker Compose（如未安装，见下方"安装 Docker"）

### 一键部署命令

**只需复制下面这一整段代码，粘贴到你的设备终端（SSH）里，回车即可！**

```bash
# 创建项目目录并进入
mkdir -p /home/pairdrop && cd /home/pairdrop

# 写入配置文件
cat <<'EOF' > docker-compose.yml
services:
  pairdrop:
    image: ghcr.io/1williamaoayers/pairdrop-arm32:latest
    container_name: pairdrop
    restart: always
    ports:
      - "3008:3000"
    environment:
      - WS_FALLBACK=false
      - RATE_LIMIT=false
      - RTC_CONFIG=false
      - DEBUG_MODE=false
      - TZ=Asia/Shanghai
EOF

# 启动服务
docker compose up -d

# 显示成功提示
echo "✅ 部署成功！访问地址：http://设备IP:3008"
```

> **💡 提示**：
> - 安装目录：`/home/pairdrop`
> - 访问端口：`3008`
> - 如需修改配置，编辑 `/home/pairdrop/docker-compose.yml` 后执行 `docker compose up -d` 重启

### ✅ 部署完成

执行完上面的命令后，你会看到类似这样的输出：

```
Creating network "pairdrop_default" with the default driver
Creating pairdrop ... done
```

这就说明部署成功了！🎉

---

## 💻 如何使用

### 1️⃣ 查看设备 IP 地址

如果你不知道玩客云的 IP 地址，在终端输入：

```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

会显示类似这样的结果：

```
inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
```

这里的 `192.168.1.100` 就是你的设备 IP。

### 2️⃣ 在浏览器打开

在**同一局域网**内的任何设备（手机、电脑、平板）上，打开浏览器，输入：

```
http://192.168.1.100:3008
```

（把 `192.168.1.100` 替换成你的实际 IP）

### 3️⃣ 开始传文件 🎉

- 打开后会看到局域网内所有打开 PairDrop 的设备
- 点击设备图标，选择文件，秒传！
- 支持多文件、大文件，速度取决于你的 Wi-Fi

---

## 📱 手机也能用吗？

**当然可以！** 而且超级方便：

1. 手机连接同一个 Wi-Fi
2. 打开浏览器（Safari、Chrome 都行）
3. 输入 `http://设备IP:3008`
4. 添加到主屏幕，就像一个 App 一样使用

---

## 🛠️ 常用命令

```bash
# 查看运行状态
docker compose ps

# 查看日志（排查问题）
docker compose logs -f

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 更新到最新版本
docker compose pull
docker compose up -d
```

---

## 🗑️ 如何彻底卸载（后悔药）

如果你不想用了，想完全删除，复制下面这段命令：

```bash
# 进入项目目录
cd /home/pairdrop

# 停止并删除容器
docker compose down

# 删除镜像（释放空间）
docker rmi ghcr.io/1williamaoayers/pairdrop-arm32:latest

# 删除整个项目文件夹
cd / && rm -rf /home/pairdrop

# 验证清理完成
docker ps -a | grep pairdrop
docker images | grep pairdrop
```

执行完后，系统里不会留下任何痕迹。✨

---

## 🐳 还没安装 Docker？

如果你的设备还没装 Docker，先执行这个：

```bash
# 使用官方安装脚本（适用于大多数 Linux 发行版）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将当前用户添加到 docker 组（避免每次用 sudo）
sudo usermod -aG docker $USER

# 重新登录或执行以下命令使组权限生效
newgrp docker

# 验证安装
docker --version
docker-compose --version
```

---

## ❓ 常见问题

### Q1: 访问不了怎么办？

**检查清单**：
- ✅ 设备和手机在同一个 Wi-Fi 下
- ✅ 防火墙没有拦截 3008 端口
- ✅ IP 地址输入正确
- ✅ 容器正在运行（`docker compose ps` 查看）

### Q2: 端口被占用了？

修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8080:3000"  # 改成其他端口，比如 8080
```

然后重启：`docker compose up -d`

### Q3: 设备找不到彼此？

尝试启用 WebSocket 降级：

```yaml
environment:
  - WS_FALLBACK=true
```

### Q4: 玩客云性能够用吗？

**完全够用！** PairDrop 是轻量级应用，ARM32 设备跑起来毫无压力。文件传输走的是点对点连接，不经过服务器，玩客云只负责"牵线搭桥"。

### Q5: 镜像拉取很慢怎么办？

可以配置 Docker 镜像加速器（国内用户推荐）：

```bash
# 编辑 Docker 配置
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF

# 重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## 🌟 特性

- 🚀 **秒传文件**：局域网直连，速度飞快
- 🔒 **隐私安全**：文件不上传服务器，点对点传输
- 📱 **跨平台**：iOS、Android、Windows、Mac、Linux 全支持
- 🌐 **无需安装**：打开浏览器就能用
- 🎨 **界面美观**：现代化设计，操作简单
- 🔗 **设备配对**：通过 6 位数字码永久配对设备
- 🌍 **公网传输**：支持临时公共房间，跨网络传文件

---

## 👨‍💻 开发者说明

### 镜像标签说明

本项目提供两个镜像标签：

- **`:latest`** - 稳定版本（推荐普通用户使用）
  - 对应 `main` 分支的最新稳定代码
  - 经过基本测试，适合生产环境
  - 镜像地址：`ghcr.io/1williamaoayers/pairdrop-arm32:latest`

- **`:main`** - 开发版本（仅供测试）
  - 对应 `main` 分支的最新提交
  - 可能包含未充分测试的新特性
  - 镜像地址：`ghcr.io/1williamaoayers/pairdrop-arm32:main`

### 使用开发版

如果你想尝试最新的开发版本，修改 `docker-compose.yml`：

```yaml
image: ghcr.io/1williamaoayers/pairdrop-arm32:main
```

然后重新部署：

```bash
docker compose pull
docker compose up -d
```

### 支持的架构

本镜像支持以下 CPU 架构：

- `linux/amd64` - x86_64（普通 PC、服务器）
- `linux/arm64` - ARM64（树莓派 4、N1 等）
- `linux/arm/v7` - ARM32（玩客云、树莓派 3 等）

Docker 会自动选择适合你设备的架构版本。

### 构建说明

本项目使用 GitHub Actions 自动构建多架构镜像：

- 推送到 `main` 分支时，自动构建并推送 `:latest` 和 `:main` 标签
- 创建版本标签（如 `v1.0.0`）时，自动构建并推送版本标签

---

## 📚 更多文档

- [详细部署指南](DEPLOYMENT.md) - 包含高级配置和故障排查
- [原项目地址](https://github.com/schlagmichdoch/PairDrop) - PairDrop 官方仓库
- [GitHub Container Registry](https://github.com/1williamaoayers/PairDrop-arm32/pkgs/container/pairdrop-arm32) - 镜像仓库

---

## 💖 支持项目

如果觉得好用，欢迎：

- ⭐ Star 本项目
- 🐛 提交 Bug 反馈
- 💡 提出功能建议
- 📢 分享给朋友

---

## 📜 许可证

本项目基于 [PairDrop](https://github.com/schlagmichdoch/PairDrop) 项目，遵循其原有开源许可证。

---

<div align="center">
  <p>Made with ❤️ for 玩客云/树莓派玩家</p>
  <p>享受局域网文件传输的乐趣吧！🎉</p>
</div>
