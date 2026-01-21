class ServerMonitorService
  def initialize(server)
    @server = server
  end

  def call
    metrics = fetch_metrics
    return nil unless metrics

    @server.server_metrics.create!(metrics)
  end

  private

  def fetch_metrics
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
      # Fetch OS info if not already set
      fetch_os_info(ssh) if @server.os_name.blank?

      @server.update(last_error: nil, last_checked_at: Time.current)
      {
        cpu_usage: fetch_cpu_usage(ssh),
        cpu_cores: fetch_cpu_cores(ssh),
        memory_usage: fetch_memory_usage(ssh),
        memory_total: fetch_memory_total(ssh),
        disk_usage: fetch_disk_usage(ssh),
        disk_total: fetch_disk_total(ssh)
      }
    end
  rescue Net::SSH::AuthenticationFailed => e
    # 提取更友好的错误信息
    friendly_message = if e.message.include?("Authentication failed")
      "SSH 认证失败：用户名或密码/私钥不正确"
    else
      "SSH 认证失败：#{e.message}"
    end
    handle_error(friendly_message)
    raise RuntimeError, friendly_message
  rescue Net::SSH::ConnectionTimeout, Errno::ETIMEDOUT => e
    error_message = "连接超时: #{e.message}"
    handle_error(error_message)
    raise RuntimeError, error_message
  rescue Errno::ECONNREFUSED => e
    error_message = "连接被拒绝: #{e.message}"
    handle_error(error_message)
    raise RuntimeError, error_message
  rescue SocketError => e
    error_message = "网络错误: #{e.message}"
    handle_error(error_message)
    raise RuntimeError, error_message
  rescue Net::SSH::Exception => e
    error_message = "SSH错误: #{e.message}"
    handle_error(error_message)
    raise RuntimeError, error_message
  end

  def handle_error(message)
    Rails.logger.error "SSH connection failed for #{@server.name}: #{message}"
    @server.update(last_error: message, last_checked_at: Time.current)
    nil
  end

  def fetch_os_info(ssh)
    # Get OS name and version from /etc/os-release
    os_release = exec_command(ssh, "cat /etc/os-release 2>/dev/null || cat /etc/redhat-release 2>/dev/null || echo ''")

    os_name = nil
    os_version = nil

    if os_release.include?("PRETTY_NAME")
      # Parse /etc/os-release format
      os_release.each_line do |line|
        if line.start_with?("ID=")
          os_name = line.split("=").last.strip.delete('"').capitalize
        elsif line.start_with?("VERSION_ID=")
          os_version = line.split("=").last.strip.delete('"')
        end
      end
    elsif os_release.present?
      # Fallback for older systems (e.g., CentOS 6)
      os_name = os_release.strip
    end

    # Get kernel version
    kernel_version = exec_command(ssh, "uname -r").strip rescue nil

    @server.update(
      os_name: os_name,
      os_version: os_version,
      kernel_version: kernel_version
    )
  rescue => e
    Rails.logger.warn "Failed to fetch OS info for #{@server.name}: #{e.message}"
  end

  def fetch_cpu_cores(ssh)
    result = exec_command(ssh, "nproc")
    result.to_i
  rescue
    1
  end

  def fetch_cpu_usage(ssh)
    result = exec_command(ssh, "top -bn1 | grep 'Cpu(s)' | awk '{print $2}'")
    result.to_f
  rescue
    0.0
  end

  def fetch_memory_usage(ssh)
    result = exec_command(ssh, "free -m | awk 'NR==2{print $3}'")
    result.to_f
  rescue
    0.0
  end

  def fetch_memory_total(ssh)
    result = exec_command(ssh, "free -m | awk 'NR==2{print $2}'")
    result.to_f
  rescue
    0.0
  end

  def fetch_disk_usage(ssh)
    result = exec_command(ssh, "df -BG / | awk 'NR==2{print $3}' | sed 's/G//'")
    result.to_f
  rescue
    0.0
  end

  def fetch_disk_total(ssh)
    result = exec_command(ssh, "df -BG / | awk 'NR==2{print $2}' | sed 's/G//'")
    result.to_f
  rescue
    0.0
  end

  # Execute command with LC_ALL=C to avoid locale warnings
  # and ensure consistent output format
  def exec_command(ssh, command)
    result = ssh.exec!("LC_ALL=C #{command}")
    filter_shell_warnings(result)
  end

  # Filter out shell initialization warnings (e.g., locale warnings)
  # that appear before command output
  def filter_shell_warnings(output)
    return "" if output.blank?

    result = output.dup

    # Remove inline locale warnings (warning and output on same line)
    # Pattern: /path/to/script.sh: line N: warning: setlocale: ... (locale)
    result.gsub!(%r{/etc/profile[^\n]*warning:[^\n]*cannot change locale[^\n]*\([^)]+\)\s*}i, "")

    # Also filter complete warning lines
    result = result.lines.reject do |line|
      line.include?("warning:") && (
        line.include?("/etc/profile") ||
        line.include?("setlocale") ||
        line.include?("cannot change locale")
      )
    end.join

    result.strip
  end
end
