# ============================================
# 构建阶段：安装依赖
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装构建依赖（用于编译可能包含 C++ 绑定的 npm 包）
# 这对于 Alpine + ARM32 环境至关重要
RUN apk add --no-cache python3 make g++

# 安装生产依赖
RUN npm ci --omit=dev --production

# ============================================
# 运行阶段：最小化镜像
# ============================================
FROM node:20-alpine

WORKDIR /app

# 安装 tzdata 并设置时区为 Asia/Shanghai
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

# 从构建阶段复制 node_modules
COPY --from=builder /app/node_modules ./node_modules

# 复制应用代码（.dockerignore 会排除不需要的文件）
COPY . .

# 环境变量设置
ENV NODE_ENV="production" \
    TZ="Asia/Shanghai"

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000 || exit 1

# 使用 node 用户运行（安全最佳实践）
USER node

# 启动应用
CMD ["npm", "start"]