namespace :db do
  namespace :encryption do
    desc "初始化 Active Record Encryption 并自动添加到 credentials"
    task init_with_credentials: :environment do
      # 生成加密密钥
      puts "正在生成 Active Record Encryption 密钥..."
      
      primary_key = SecureRandom.alphanumeric(32)
      deterministic_key = SecureRandom.alphanumeric(32)
      key_derivation_salt = SecureRandom.alphanumeric(32)
      
      puts "\n生成的密钥："
      puts "primary_key: #{primary_key}"
      puts "deterministic_key: #{deterministic_key}"
      puts "key_derivation_salt: #{key_derivation_salt}"
      
      puts "\n请运行以下命令添加密钥到 credentials："
      puts "EDITOR=vim bin/rails credentials:edit"
      puts "\n然后在文件中添加以下内容："
      puts "\nactive_record_encryption:"
      puts "  primary_key: #{primary_key}"
      puts "  deterministic_key: #{deterministic_key}"
      puts "  key_derivation_salt: #{key_derivation_salt}"
      
      # 尝试自动添加到 credentials（如果可能）
      credentials_path = Rails.root.join("config", "credentials.yml.enc")
      
      if Rails.env.development?
        puts "\n提示：你可以使用以下命令手动编辑 credentials："
        puts "EDITOR='code --wait' bin/rails credentials:edit"
        puts "或"
        puts "EDITOR=vim bin/rails credentials:edit"
      end
    end

    desc "初始化 Active Record Encryption（用于 Docker 环境，生成环境变量格式）"
    task init: :environment do
      # 检查是否已经通过环境变量配置
      if ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"].present? &&
         ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"].present? &&
         ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"].present?
        puts "加密密钥已通过环境变量配置，跳过初始化"
        return
      end

      # 检查是否已经通过 credentials 配置
      begin
        if Rails.application.credentials.dig(:active_record_encryption, :primary_key).present? &&
           Rails.application.credentials.dig(:active_record_encryption, :deterministic_key).present? &&
           Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt).present?
          puts "加密密钥已通过 credentials 配置，跳过初始化"
          return
        end
      rescue => e
        # 如果无法读取 credentials（比如没有 master key），继续生成新密钥
      end

      # 检查 .env 文件是否已包含密钥
      env_file = Rails.root.join(".env")
      if File.exist?(env_file)
        env_content = File.read(env_file)
        if env_content.include?("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=")
          # 从 .env 文件读取密钥
          primary_key = env_content.match(/^ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=(.+)$/m)&.[](1)&.strip
          deterministic_key = env_content.match(/^ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=(.+)$/m)&.[](1)&.strip
          key_derivation_salt = env_content.match(/^ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=(.+)$/m)&.[](1)&.strip
          
          if primary_key.present? && deterministic_key.present? && key_derivation_salt.present?
            puts "从 .env 文件读取到已有加密密钥，跳过生成"
            # 设置环境变量
            ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] = primary_key
            ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] = deterministic_key
            ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] = key_derivation_salt
            return
          end
        end
      end

      # 生成加密密钥
      primary_key = SecureRandom.alphanumeric(32)
      deterministic_key = SecureRandom.alphanumeric(32)
      key_derivation_salt = SecureRandom.alphanumeric(32)
      
      # 输出环境变量格式（用于 Docker）
      puts "正在生成加密密钥..."
      
      # 尝试写入 .env 文件
      begin
        File.open(env_file, "a") do |f|
          f.puts "\n# Active Record Encryption Keys (自动生成于 #{Time.now})"
          f.puts "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=#{primary_key}"
          f.puts "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=#{deterministic_key}"
          f.puts "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=#{key_derivation_salt}"
        end
        puts "密钥已写入 .env 文件"
      rescue => e
        puts "警告: 无法写入 .env 文件: #{e.message}"
        puts "请手动将以下环境变量添加到 .env 文件或 Docker 配置中："
        puts "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=#{primary_key}"
        puts "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=#{deterministic_key}"
        puts "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=#{key_derivation_salt}"
      end
      
      # 设置环境变量（当前进程）
      ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] = primary_key
      ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] = deterministic_key
      ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] = key_derivation_salt
      
      # 重新加载配置
      Rails.application.config.active_record.encryption.primary_key = primary_key
      Rails.application.config.active_record.encryption.deterministic_key = deterministic_key
      Rails.application.config.active_record.encryption.key_derivation_salt = key_derivation_salt
      
      puts "加密密钥已初始化并应用到当前环境"
    end
  end
end
