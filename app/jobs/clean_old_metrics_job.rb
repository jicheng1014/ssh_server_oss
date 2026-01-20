class CleanOldMetricsJob < ApplicationJob
  queue_as :default

  def perform
    # 获取配置的保留天数（1-90天，默认30天）
    retention_days = SystemSetting.metrics_retention_days
    cutoff_date = retention_days.days.ago

    # 删除指定天数之前的检测日志
    deleted_count = ServerMetric.where("created_at < ?", cutoff_date).delete_all

    Rails.logger.info "CleanOldMetricsJob: 已清理 #{deleted_count} 条 #{retention_days} 天前的检测日志（截止日期: #{cutoff_date.strftime('%Y-%m-%d %H:%M:%S')}）"
  end
end
