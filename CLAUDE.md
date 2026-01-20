# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Server Monitor - A personal Rails application for monitoring multiple remote servers via SSH. Collects CPU, memory, and disk usage metrics every 10 minutes using Solid Queue for scheduled jobs.

## Tech Stack

- Rails 8.1 with SQLite
- TailwindCSS v4 for styling
- Hotwire (Turbo + Stimulus) for frontend interactivity
- Solid Queue for background jobs and recurring tasks
- Solid Cache and Solid Cable for caching and WebSocket
- net-ssh gem for SSH connections

## Common Commands

```bash
# Start development server (runs Rails + Tailwind watcher)
bin/dev

# Run database migrations
bin/rails db:migrate

# Start background job processor (required for monitoring)
bin/jobs

# Run tests
bin/rails test

# Run a single test file
bin/rails test test/models/server_test.rb

# Rails console
bin/rails console

# Manual monitoring trigger
bin/rails runner "MonitorServersJob.perform_now"
```

## Architecture

### Models
- `Server` - stores server connection info (host, port, username, active status)
- `ServerMetric` - stores collected metrics (cpu_usage, memory_usage/total, disk_usage/total)

### Services
- `ServerMonitorService` - connects to a single server via SSH and collects metrics
- `MonitorAllServersService` - iterates through active servers and triggers monitoring

### Jobs
- `MonitorServersJob` - scheduled every 10 minutes via Solid Queue (config/recurring.yml)

### SSH Configuration

SSH 私钥支持多种配置方式（按优先级排序）：

**方式一：直接复制文件（推荐）**
```bash
# 从默认位置导入
bin/rails ssh:import

# 或指定文件路径
bin/rails ssh:import[/path/to/your/private_key]
```

**方式二：环境变量**
```bash
# 直接设置私钥内容
export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"

# 或指定私钥文件路径
export SSH_KEY_PATH=~/.ssh/id_rsa
```

**方式三：Rails credentials**
```bash
EDITOR=vim bin/rails credentials:edit

# 添加:
ssh:
  private_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...your private key content...
    -----END OPENSSH PRIVATE KEY-----
```

**SSH 相关命令**
```bash
# 查看配置状态
bin/rails ssh:status

# 测试连接
bin/rails ssh:test
bin/rails ssh:test[server_id]
```

### Active Record Encryption

服务器密码和私钥使用 Active Record Encryption 加密存储。首次使用需要配置加密密钥：

**1. 生成加密密钥**
```bash
bin/rails db:encryption:init
```

**2. 将密钥添加到 credentials**
```bash
EDITOR=vim bin/rails credentials:edit
```

添加以下内容（使用 `db:encryption:init` 生成的密钥）：
```yaml
active_record_encryption:
  primary_key: <生成的 primary_key>
  deterministic_key: <生成的 deterministic_key>
  key_derivation_salt: <生成的 key_derivation_salt>
```

**注意：**
- 加密密钥存储在 Rails credentials 中，请妥善保管
- 如果丢失加密密钥，已加密的数据将无法解密
- 私钥和密码字段会自动加密/解密，无需手动处理

## Key Files

- `app/services/server_monitor_service.rb` - SSH connection and metrics collection logic
- `config/recurring.yml` - Solid Queue scheduled job configuration
- `app/controllers/servers_controller.rb` - CRUD and manual refresh actions
