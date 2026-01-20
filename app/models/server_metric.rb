class ServerMetric < ApplicationRecord
  belongs_to :server

  def memory_usage_percent
    return 0 if memory_total.nil? || memory_total.zero?
    (memory_usage / memory_total * 100).round(1)
  end

  def disk_usage_percent
    return 0 if disk_total.nil? || disk_total.zero?
    (disk_usage / disk_total * 100).round(1)
  end
end
