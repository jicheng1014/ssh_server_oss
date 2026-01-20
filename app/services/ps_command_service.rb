class PsCommandService
  def initialize(server, format: "aux")
    @server = server
    @format = format # aux, ef, 或其他格式
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
      # 执行 ps 命令
      # 根据格式选择命令，如果失败则尝试备选方案
      result = case @format
      when "aux"
        begin
          ssh.exec!("ps aux 2>/dev/null")
        rescue
          ssh.exec!("ps -ef 2>/dev/null")
        end
      when "ef"
        begin
          ssh.exec!("ps -ef 2>/dev/null")
        rescue
          ssh.exec!("ps aux 2>/dev/null")
        end
      else
        # 默认使用 ps aux
        begin
          ssh.exec!("ps aux 2>/dev/null")
        rescue
          ssh.exec!("ps -ef 2>/dev/null")
        end
      end
      
      {
        success: true,
        output: result.to_s.strip,
        timestamp: Time.current,
        format: @format
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
