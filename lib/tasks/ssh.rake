namespace :ssh do
  desc "查看当前 SSH 私钥配置状态"
  task status: :environment do
    puts "SSH 私钥配置状态:"
    puts "  来源: #{SshKeyService.source}"
    puts "  状态: #{SshKeyService.configured? ? '已配置' : '未配置'}"

    if SshKeyService.configured?
      key = SshKeyService.private_key
      puts "  密钥长度: #{key.length} 字符"
      puts "  密钥类型: #{key.include?('OPENSSH') ? 'OpenSSH' : 'PEM'}"
    end
  end

  desc "从文件导入 SSH 私钥到 config/ssh/id_rsa"
  task :import, [:key_path] => :environment do |t, args|
    key_path = args[:key_path] || File.expand_path("~/.ssh/id_rsa")

    unless File.exist?(key_path)
      puts "错误: 文件不存在 #{key_path}"
      puts "用法: bin/rails ssh:import[/path/to/your/private_key]"
      exit 1
    end

    target_path = Rails.root.join("config", "ssh", "id_rsa")
    FileUtils.mkdir_p(File.dirname(target_path))
    FileUtils.cp(key_path, target_path)
    FileUtils.chmod(0600, target_path)

    puts "SSH 私钥已导入到 #{target_path}"
    puts "请确保该文件已添加到 .gitignore（默认已配置）"
  end

  desc "测试 SSH 连接"
  task :test, [:server_id] => :environment do |t, args|
    unless SshKeyService.configured?
      puts "错误: SSH 私钥未配置"
      puts ""
      puts "配置方式（任选其一）:"
      puts "  1. 复制私钥文件: bin/rails ssh:import[~/.ssh/id_rsa]"
      puts "  2. 设置环境变量: export SSH_PRIVATE_KEY=\"$(cat ~/.ssh/id_rsa)\""
      puts "  3. 指定文件路径: export SSH_KEY_PATH=~/.ssh/id_rsa"
      exit 1
    end

    server = if args[:server_id]
      Server.find(args[:server_id])
    else
      Server.first
    end

    unless server
      puts "错误: 没有找到服务器"
      exit 1
    end

    puts "测试连接: #{server.name} (#{server.username}@#{server.host}:#{server.port})"
    puts "SSH 密钥来源: #{SshKeyService.source}"
    puts ""

    begin
      Net::SSH.start(
        server.host,
        server.username,
        port: server.port,
        key_data: [SshKeyService.private_key],
        non_interactive: true,
        timeout: 10,
        verify_host_key: :never
      ) do |ssh|
        result = ssh.exec!("uname -a")
        puts "连接成功!"
        puts "系统信息: #{result.strip}"
      end
    rescue => e
      puts "连接失败: #{e.message}"
      exit 1
    end
  end
end
