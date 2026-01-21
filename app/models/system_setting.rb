# == Schema Information
#
# Table name: system_settings
# Database name: primary
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_system_settings_on_key  (key) UNIQUE
#
class SystemSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # 获取配置值
  def self.get(key, default = nil)
    setting = find_by(key: key)
    setting ? setting.value : default
  end

  # 设置配置值
  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.save!
  end

  # 获取监控任务频率（分钟）
  def self.monitor_interval
    get("monitor_interval", "10").to_i
  end

  # 设置监控任务频率（分钟）
  def self.monitor_interval=(minutes)
    set("monitor_interval", minutes.to_s)
  end

  # 获取日志保留天数（1-90天，默认30天）
  def self.metrics_retention_days
    days = get("metrics_retention_days", "30").to_i
    # 确保在有效范围内
    days = 30 if days < 1 || days > 90
    days
  end

  # 设置日志保留天数（1-90天）
  def self.metrics_retention_days=(days)
    days = days.to_i
    # 限制在有效范围内
    days = [[days, 1].max, 90].min
    set("metrics_retention_days", days.to_s)
  end

  # 系统级私钥配置（使用加密存储）
  # 注意：这里使用一个特殊的 SystemPrivateKey 模型来处理加密
  def self.system_private_key
    record = SystemPrivateKey.first
    return nil unless record

    begin
      record.private_key
    rescue ActiveRecord::Encryption::Errors::Decryption => e
      # 如果解密失败（可能是加密密钥已更改），返回 nil
      Rails.logger.warn "无法解密系统私钥: #{e.message}"
      nil
    end
  end

  def self.system_private_key=(key)
    if key.present?
      record = SystemPrivateKey.first_or_initialize
      record.private_key = key
      record.save!
    else
      SystemPrivateKey.destroy_all
    end
  end

  def self.system_private_key_configured?
    # 尝试读取私钥，如果能成功读取则返回 true
    # 如果解密失败，返回 false（避免因解密错误导致的问题）
    system_private_key.present?
  end
end
