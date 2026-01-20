# Active Record Encryption 配置
# 加密密钥存储在 Rails credentials 中
# 
# 如果还没有配置，请运行以下命令生成密钥：
#   bin/rails db:encryption:init
#
# 然后将生成的密钥添加到 credentials：
#   EDITOR=vim bin/rails credentials:edit
#
# 添加以下内容：
#   active_record_encryption:
#     primary_key: <生成的 primary_key>
#     deterministic_key: <生成的 deterministic_key>
#     key_derivation_salt: <生成的 key_derivation_salt>

Rails.application.config.active_record.encryption.primary_key = Rails.application.credentials.dig(:active_record_encryption, :primary_key)
Rails.application.config.active_record.encryption.deterministic_key = Rails.application.credentials.dig(:active_record_encryption, :deterministic_key)
Rails.application.config.active_record.encryption.key_derivation_salt = Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt)
