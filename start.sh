#!/bin/bash

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Server Monitor - 一键启动脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未检测到 Docker，请先安装 Docker${NC}"
    echo "访问 https://docs.docker.com/get-docker/ 获取安装指南"
    exit 1
fi

# 检查 Docker Compose 是否可用
if ! docker compose version &> /dev/null && ! docker-compose version &> /dev/null; then
    echo -e "${RED}错误: 未检测到 Docker Compose${NC}"
    exit 1
fi

# 确定使用 docker compose 还是 docker-compose
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo -e "${YELLOW}步骤 1/4: 检查 Docker 环境...${NC}"
if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker 守护进程未运行，请启动 Docker${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker 环境正常${NC}"
echo ""

# 创建必要的目录
echo -e "${YELLOW}步骤 2/4: 准备目录和文件...${NC}"
mkdir -p storage
touch .env 2>/dev/null || true
echo -e "${GREEN}✓ 目录准备完成${NC}"
echo ""

# 构建镜像
echo -e "${YELLOW}步骤 3/4: 构建 Docker 镜像...${NC}"
$DOCKER_COMPOSE build
echo -e "${GREEN}✓ 镜像构建完成${NC}"
echo ""

# 启动服务
echo -e "${YELLOW}步骤 4/4: 启动服务...${NC}"
$DOCKER_COMPOSE up -d

# 等待服务启动
echo ""
echo -e "${YELLOW}等待服务启动...${NC}"
sleep 5

# 检查服务状态
if $DOCKER_COMPOSE ps | grep -q "Up"; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  服务启动成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "访问地址: ${GREEN}http://localhost:3000${NC}"
    echo ""
    echo "常用命令："
    echo "  查看日志:     $DOCKER_COMPOSE logs -f"
    echo "  停止服务:     $DOCKER_COMPOSE down"
    echo "  重启服务:     $DOCKER_COMPOSE restart"
    echo "  查看状态:     $DOCKER_COMPOSE ps"
    echo ""
    echo -e "${YELLOW}提示:${NC}"
    echo "  - 数据库文件存储在 ./storage 目录"
    echo "  - 加密密钥会自动生成并保存在 .env 文件中"
    echo "  - 首次启动会自动初始化数据库和加密密钥"
    echo ""
else
    echo -e "${RED}服务启动失败，请查看日志:${NC}"
    $DOCKER_COMPOSE logs
    exit 1
fi
