class TopCommandService
  def initialize(server)
    @server = server
  end

  def call
    raise "SSH 认证信息未配置" unless @server.has_authentication?

    auth_options = @server.authentication_options

    Net::SSH.start(
      @server.host,
      @server.username,
      port: @server.port,
      non_interactive: true,
      timeout: 10,
      verify_host_key: :never,
      **auth_options
    ) do |ssh|
      # 执行 top 命令，获取一次快照（非交互式）
      # 尝试多种 top 命令格式以兼容不同系统
      result = begin
        # Linux: top -bn1
        ssh.exec!("timeout 5 top -bn1 2>/dev/null")
      rescue
        begin
          # macOS: top -l 1
          ssh.exec!("top -l 1 2>/dev/null")
        rescue
          begin
            # 备选方案: ps aux 按 CPU 排序
            ssh.exec!("ps aux --sort=-%cpu | head -20 2>/dev/null")
          rescue
            # 最后的备选方案: 简单的 ps aux
            ssh.exec!("ps aux | head -20 2>/dev/null")
          end
        end
      end

      {
        success: true,
        output: result.to_s.strip,
        timestamp: Time.current
      }
    end
  rescue Net::SSH::AuthenticationFailed => e
    {
      success: false,
      error: "认证失败: #{e.message}",
      timestamp: Time.current
    }
  rescue Net::SSH::ConnectionTimeout, Errno::ETIMEDOUT => e
    {
      success: false,
      error: "连接超时: #{e.message}",
      timestamp: Time.current
    }
  rescue Errno::ECONNREFUSED => e
    {
      success: false,
      error: "连接被拒绝: #{e.message}",
      timestamp: Time.current
    }
  rescue SocketError => e
    {
      success: false,
      error: "网络错误: #{e.message}",
      timestamp: Time.current
    }
  rescue Net::SSH::Exception => e
    {
      success: false,
      error: "SSH错误: #{e.message}",
      timestamp: Time.current
    }
  rescue => e
    {
      success: false,
      error: "未知错误: #{e.message}",
      timestamp: Time.current
    }
  end
end
