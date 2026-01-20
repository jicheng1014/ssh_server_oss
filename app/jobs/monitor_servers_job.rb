class MonitorServersJob < ApplicationJob
  queue_as :default

  def perform
    # 获取配置的监控间隔（分钟）
    interval_minutes = SystemSetting.monitor_interval

    # 检查上次执行时间
    last_run_key = "monitor_servers_last_run"
    last_run_time = SystemSetting.get(last_run_key)

    if last_run_time.present?
      last_run = Time.parse(last_run_time)
      time_since_last_run = Time.current - last_run

      # 如果距离上次执行还没到配置的间隔时间，跳过本次执行
      if time_since_last_run < interval_minutes * 60
        Rails.logger.debug "MonitorServersJob: 距离上次执行仅 #{time_since_last_run.to_i} 秒，间隔需要 #{interval_minutes} 分钟，跳过本次执行"
        return
      end
    end

    # 执行监控任务
    MonitorAllServersService.new.call

    # 更新上次执行时间
    SystemSetting.set(last_run_key, Time.current.to_s)
  end
end
