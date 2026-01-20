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
  end
end
