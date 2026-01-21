# Server Monitor - 服务器监控系统

## 📢 项目简介

如果你有多台服务器分布在不同的服务商（如 AWS、阿里云、腾讯云、Bandwagon 等），不想没事登录各个服务商,又要避免遗漏某些机器挂掉或者磁盘满了这种简单需求，那么这个项目适合你！

这是一个基于 Rails 的轻量级服务器监控系统，通过 SSH 连接远程服务器，实时收集 CPU、内存、磁盘使用情况，让你一眼看完不同服务商的服务器状态。

## 他不是什么
不是堡垒机, 也不是运维自动化工具, 只是一个简单的服务器状态监控系统。

## 🤔 为什么不用其他开源产品？

市面上有很多成熟的监控系统（如 Prometheus + Grafana、Zabbix、Nagios 等），但这个项目选择了更简单的方案，原因如下：

### 1. ** 基于 Rails **
- 代码结构清晰，易于维护和扩展
- 内置的 Active Record、Action Cable、Solid Queue 等组件开箱即用

### 2. **获取原理简单**
- 直接通过 SSH 执行系统命令（`top`、`free`、`df`）获取指标
- 无需在目标服务器安装任何 Agent 或监控程序
- 逻辑透明，易于理解和调试

### 3. **远端服务器零依赖**
- **只需要 SSH 访问权限**，这是最核心的优势
- 不需要安装额外的监控 Agent
- 不需要开放额外的端口
- 不需要配置复杂的网络规则
- 适用于任何支持 SSH 的 Linux 服务器

### 4. **轻量级部署**
- 使用 SQLite 数据库，无需单独的数据库服务器
- 单机部署即可运行
- 资源占用低，适合个人或小团队使用

## 🚀 快速开始

### 方式一：Docker 一键启动（推荐，最简单）

**系统要求：**
- Docker 和 Docker Compose

**启动步骤：**

1. **克隆项目**
```bash
git clone <repository-url>
cd ssh_server
```

2. **一键启动**
```bash
./start.sh
```

就这么简单！脚本会自动完成：
- ✅ 检查 Docker 环境
- ✅ 构建 Docker 镜像
- ✅ 初始化数据库
- ✅ 自动生成加密密钥
- ✅ 启动 Web 服务和后台任务处理器

3. **访问应用**
打开浏览器访问 `http://localhost:3000`

**常用命令：**
```bash
# 查看日志
docker compose logs -f

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看服务状态
docker compose ps
```

**数据持久化：**
- 数据库文件存储在 `./storage` 目录
- 加密密钥自动保存在 `.env` 文件中（首次启动后生成）

---

### 方式二：本地开发环境

**系统要求：**

- Ruby 3.4+
- Node.js 18+（用于 TailwindCSS）
- SQLite 3.8+

**安装步骤：**

1. **克隆项目**
```bash
git clone <repository-url>
cd ssh_server
```

2. **安装依赖**
```bash
bundle install
npm install
```

3. **配置数据库**
```bash
bin/rails db:create db:migrate
```

4. **配置加密密钥（首次使用必须）**
```bash
# 生成加密密钥
bin/rails db:encryption:init

# 编辑 credentials，添加生成的密钥
EDITOR=vim bin/rails credentials:edit
```

在 credentials 中添加：
```yaml
active_record_encryption:
  primary_key: <生成的 primary_key>
  deterministic_key: <生成的 deterministic_key>
  key_derivation_salt: <生成的 key_derivation_salt>
```

5. **配置 SSH 私钥（可选，也可在添加服务器时单独配置）**
```bash
# 方式一：从默认位置导入
bin/rails ssh:import

# 方式二：指定文件路径
bin/rails ssh:import[/path/to/your/private_key]

# 方式三：使用环境变量
export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
# 或
export SSH_KEY_PATH=~/.ssh/id_rsa
```

6. **启动服务**
```bash
# 启动开发服务器（包含 Rails + Tailwind 监听器）
bin/dev

# 在另一个终端启动后台任务处理器（必须，用于定时监控）
bin/jobs
```

7. **访问应用**
打开浏览器访问 `http://localhost:3000`

## 📦 部署

### 使用 Kamal 部署（推荐）

项目已配置 Kamal 部署方案，支持 Docker 容器化部署。

1. **配置部署信息**
```bash
cp config/deploy.yml.example config/deploy.yml
# 编辑 config/deploy.yml，配置服务器信息
```

2. **配置密钥**
```bash
# 创建 .kamal/secrets 文件，添加必要的密钥
echo "RAILS_MASTER_KEY=$(cat config/master.key)" >> .kamal/secrets
```

3. **部署**
```bash
bin/kamal setup    # 首次部署
bin/kamal deploy   # 后续部署
```

### 传统部署

1. **生产环境配置**
```bash
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails assets:precompile
```

2. **启动服务**
```bash
# 使用 systemd 或 supervisor 管理进程
# 需要同时运行：
# - Puma 服务器（Web 服务）
# - Solid Queue 处理器（后台任务）
```

3. **配置反向代理**
使用 Nginx 或 Caddy 作为反向代理，指向 Puma 服务器。

### 环境变量

生产环境建议使用环境变量配置敏感信息：

```bash
# SSH 私钥
export SSH_PRIVATE_KEY="<your-private-key>"
# 或
export SSH_KEY_PATH=/path/to/private_key

# Rails Master Key（用于解密 credentials）
export RAILS_MASTER_KEY="<master-key>"
```

## 🔧 常用命令

```bash
# 开发服务器
bin/dev

# 后台任务处理器
bin/jobs

# 数据库迁移
bin/rails db:migrate

# Rails 控制台
bin/rails console

# 手动触发监控
bin/rails runner "MonitorServersJob.perform_now"

# SSH 相关命令
bin/rails ssh:status          # 查看 SSH 配置状态
bin/rails ssh:test            # 测试全局 SSH 连接
bin/rails ssh:test[server_id] # 测试特定服务器连接
```

## 📁 项目结构

```
app/
  ├── controllers/     # 控制器
  ├── models/          # 数据模型（Server, ServerMetric）
  ├── services/        # 业务逻辑（ServerMonitorService）
  ├── jobs/             # 后台任务（MonitorServersJob）
  └── views/          # 视图模板

config/
  ├── recurring.yml    # 定时任务配置
  └── deploy.yml       # Kamal 部署配置

lib/tasks/            # Rake 任务
```

## 🔐 安全与隐私

### 数据加密

- **服务器密码和 SSH 私钥**使用 Active Record Encryption 加密存储
- 加密密钥存储在 Rails credentials 中，不会提交到代码仓库
- 所有敏感字段在日志中自动过滤

### 隐私考虑

**⚠️ 开源前必须检查的事项：**

1. ✅ **敏感文件已排除**
   - `.gitignore` 已配置排除 `config/master.key`、`config/deploy.yml`、`config/ssh/*` 等敏感文件
   - 数据库文件（`storage/*.sqlite3`）已排除
   - 环境变量文件（`.env*`）已排除

2. ✅ **代码中的敏感信息**
   - 密码和私钥使用加密存储，代码中不会出现明文
   - 日志过滤已配置，敏感参数不会记录

3. ⚠️ **必须检查 Git 历史记录**

   **重要：即使文件现在在 `.gitignore` 中，如果之前提交过，仍然会在 Git 历史中！**

   检查命令：
   ```bash
   # 检查敏感文件是否在历史记录中
   git log --all --full-history --source -- "config/deploy.yml" "config/master.key" "config/ssh/*"

   # 检查是否有硬编码的 IP、域名、邮箱等
   git log -p | grep -E "192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|@.*\.com|password.*=|secret.*="
   ```

   如果发现敏感信息，**必须清理 Git 历史**：
   ```bash
   # 安装 git-filter-repo（推荐）
   pip install git-filter-repo

   # 清理敏感文件的历史记录
   git filter-repo --path config/deploy.yml --invert-paths
   git filter-repo --path config/master.key --invert-paths
   git filter-repo --path config/ssh/ --invert-paths

   # 强制推送到远程（⚠️ 会重写历史，确保团队已同步）
   git push origin --force --all
   ```

4. ⚠️ **检查当前工作目录中的敏感文件**

   即使文件在 `.gitignore` 中，也要确保：
   - `config/deploy.yml` 不包含真实的服务器 IP、域名、密码
   - `config/master.key` 不存在或已排除
   - `config/ssh/*` 目录中的私钥文件已排除
   - 测试数据（`test/fixtures/*.yml`）不包含真实信息

5. 📝 **开源建议**
   - 在 README 中明确说明需要用户自行配置加密密钥和 SSH 私钥
   - 提供示例配置文件（如 `config/deploy.yml.example`），但不包含真实数据
   - 考虑添加安全审计工具（如 `brakeman`、`bundler-audit`）到 CI/CD
   - 在首次提交前，使用 `git status` 确认没有敏感文件被意外添加

### 清理 Git 历史（如需要）

**⚠️ 警告：清理 Git 历史会重写提交记录，需要团队协作！**

如果发现历史记录中有敏感信息，可以使用以下命令清理：

```bash
# 方法一：使用 git-filter-repo（推荐，更安全）
pip install git-filter-repo

# 清理特定文件
git filter-repo --path config/deploy.yml --invert-paths
git filter-repo --path config/master.key --invert-paths

# 方法二：使用 git filter-branch（较旧的方法）
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch config/deploy.yml config/master.key" \
  --prune-empty --tag-name-filter cat -- --all

# 清理后，强制推送（⚠️ 确保团队成员已同步）
git push origin --force --all
git push origin --force --tags
```

**清理后的验证：**
```bash
# 确认文件已从历史中移除
git log --all --full-history --source -- "config/deploy.yml"
# 应该没有输出

# 检查仓库大小（清理后应该变小）
du -sh .git
```

## 🛠️ 技术栈

- **后端框架**: Rails 8.1
- **数据库**: SQLite 3
- **前端样式**: TailwindCSS v4
- **前端交互**: Hotwire (Turbo + Stimulus)
- **后台任务**: Solid Queue
- **缓存**: Solid Cache
- **WebSocket**: Solid Cable
- **SSH 连接**: net-ssh gem
- **部署**: Kamal (Docker)

## 📄 许可证

[请添加您的许可证]

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📮 联系方式

[请添加您的联系方式]
