class SettingsController < ApplicationController
  def index
    @monitor_interval = SystemSetting.monitor_interval
    @metrics_retention_days = SystemSetting.metrics_retention_days
    @ssh_key_source = SshKeyService.source
    @ssh_key_configured = SshKeyService.configured?
  end

  def update_monitor_interval
    interval = params[:monitor_interval].to_i

    if interval < 1 || interval > 1440
      redirect_to settings_path, alert: "监控频率必须在 1-1440 分钟之间"
      return
    end

    # 保存到数据库
    SystemSetting.monitor_interval = interval

    redirect_to settings_path, notice: "监控频率已更新为每 #{interval} 分钟，将在下次检查时生效"
  end

  def update_metrics_retention_days
    days = params[:metrics_retention_days].to_i

    if days < 1 || days > 90
      redirect_to settings_path, alert: "日志保留天数必须在 1-90 天之间"
      return
    end

    # 保存到数据库
    SystemSetting.metrics_retention_days = days

    redirect_to settings_path, notice: "日志保留天数已更新为 #{days} 天，清理任务将在每天凌晨 3 点自动运行"
  end

  def export_servers
    servers_data = Server.ordered.map do |server|
      {
        "name" => server.name,
        "host" => server.host,
        "port" => server.port,
        "username" => server.username,
        "active" => server.active,
        "provider" => server.provider,
        "position" => server.position
      }
    end

    yaml_content = servers_data.to_yaml

    respond_to do |format|
      format.html do
        send_data yaml_content,
                  filename: "servers_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.yml",
                  type: "application/x-yaml",
                  disposition: "attachment"
      end
    end
  end

  def import_servers
    # 显示导入页面
  end

  def import_servers_process
    uploaded_file = params[:yaml_file]

    if uploaded_file.blank?
      redirect_to import_servers_settings_path, alert: "请选择要导入的 YAML 文件"
      return
    end

    begin
      yaml_content = uploaded_file.read
      # 允许 Symbol 类型，因为导出的 YAML 可能包含 Symbol key
      servers_data = YAML.safe_load(yaml_content, permitted_classes: [Symbol], aliases: true)

      unless servers_data.is_a?(Array)
        redirect_to import_servers_settings_path, alert: "YAML 文件格式错误：应为服务器数组"
        return
      end

      imported_count = 0
      updated_count = 0
      errors = []
      max_position = Server.maximum(:position).to_i

      servers_data.each_with_index do |server_data, index|
        server_data = server_data.with_indifferent_access

        # 验证必需字段
        unless server_data[:name].present? && server_data[:host].present? && server_data[:username].present?
          errors << "第 #{index + 1} 条记录缺少必需字段（name, host, username）"
          next
        end

        # 查找是否已存在（根据 host）
        existing_server = Server.find_by(host: server_data[:host])

        if existing_server
          # 更新现有服务器
          update_params = {
            name: server_data[:name],
            port: server_data[:port] || 22,
            username: server_data[:username],
            active: server_data[:active] != false,
            provider: server_data[:provider]
          }
          update_params[:position] = server_data[:position] if server_data[:position].present?

          if existing_server.update(update_params)
            updated_count += 1
          else
            errors << "第 #{index + 1} 条记录更新失败：#{existing_server.errors.full_messages.join(', ')}"
          end
        else
          # 创建新服务器
          max_position += 1
          new_server = Server.new(
            name: server_data[:name],
            host: server_data[:host],
            port: server_data[:port] || 22,
            username: server_data[:username],
            active: server_data[:active] != false,
            provider: server_data[:provider],
            position: server_data[:position] || max_position
          )

          if new_server.save
            imported_count += 1
            max_position = [max_position, new_server.position].max
            # 如果服务器是活跃的，立即异步执行一次数据获取
            if new_server.active?
              RefreshServerJob.perform_later(new_server)
            end
          else
            errors << "第 #{index + 1} 条记录导入失败：#{new_server.errors.full_messages.join(', ')}"
          end
        end
      end

      notice_parts = []
      notice_parts << "成功导入 #{imported_count} 台服务器" if imported_count > 0
      notice_parts << "成功更新 #{updated_count} 台服务器" if updated_count > 0
      notice_parts << "有 #{errors.size} 条错误" if errors.any?

      if errors.any?
        flash[:alert] = errors.join("<br>").html_safe
      end

      redirect_to settings_path, notice: notice_parts.join("，")
    rescue Psych::SyntaxError => e
      redirect_to import_servers_settings_path, alert: "YAML 文件格式错误：#{e.message}"
    rescue => e
      redirect_to import_servers_settings_path, alert: "导入失败：#{e.message}"
    end
  end
end
