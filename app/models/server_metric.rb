# == Schema Information
#
# Table name: server_metrics
# Database name: primary
#
#  id           :integer          not null, primary key
#  cpu_cores    :integer
#  cpu_usage    :float
#  disk_total   :float
#  disk_usage   :float
#  memory_total :float
#  memory_usage :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  server_id    :integer          not null
#
# Indexes
#
#  index_server_metrics_on_server_id  (server_id)
#
# Foreign Keys
#
#  server_id  (server_id => servers.id)
#
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
