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
end
