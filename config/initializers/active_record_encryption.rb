# Active Record Encryption 配置
# 加密密钥支持多种配置方式（按优先级排序）：
# 1. 环境变量（推荐用于 Docker 部署）
# 2. Rails credentials（推荐用于传统部署）
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
#
# 或者使用环境变量（Docker 推荐）：
#   ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=<primary_key>
#   ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=<deterministic_key>
#   ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=<key_derivation_salt>

Rails.application.config.active_record.encryption.primary_key =
  ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] ||
  Rails.application.credentials.dig(:active_record_encryption, :primary_key)

Rails.application.config.active_record.encryption.deterministic_key =
  ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] ||
  Rails.application.credentials.dig(:active_record_encryption, :deterministic_key)

Rails.application.config.active_record.encryption.key_derivation_salt =
  ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] ||
  Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt)
