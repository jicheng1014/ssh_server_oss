class SshKeyService
  # SSH 私钥加载优先级:
  # 1. Rails credentials (ssh.private_key)
  # 2. 环境变量 SSH_PRIVATE_KEY
  # 3. 环境变量 SSH_KEY_PATH 指定的文件
  # 4. 默认文件路径 config/ssh/id_rsa

  DEFAULT_KEY_PATH = Rails.root.join("config", "ssh", "id_rsa")

  def self.private_key
    # 1. 从 credentials 读取
    key = Rails.application.credentials.dig(:ssh, :private_key)
    return key if key.present?

    # 2. 从环境变量读取
    key = ENV["SSH_PRIVATE_KEY"]
    return key if key.present?

    # 3. 从环境变量指定的文件读取
    if ENV["SSH_KEY_PATH"].present? && File.exist?(ENV["SSH_KEY_PATH"])
      return File.read(ENV["SSH_KEY_PATH"])
    end

    # 4. 从默认文件路径读取
    if File.exist?(DEFAULT_KEY_PATH)
      return File.read(DEFAULT_KEY_PATH)
    end

    nil
  end

  def self.configured?
    private_key.present?
  end

  def self.source
    if Rails.application.credentials.dig(:ssh, :private_key).present?
      "Rails credentials"
    elsif ENV["SSH_PRIVATE_KEY"].present?
      "环境变量 SSH_PRIVATE_KEY"
    elsif ENV["SSH_KEY_PATH"].present? && File.exist?(ENV["SSH_KEY_PATH"])
      "文件: #{ENV['SSH_KEY_PATH']}"
    elsif File.exist?(DEFAULT_KEY_PATH)
      "文件: #{DEFAULT_KEY_PATH}"
    else
      "未配置"
    end
  end
end
