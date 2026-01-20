class DashboardController < ApplicationController
  def index
    @servers = Server.includes(:server_metrics).active.ordered

    # Get latest metrics for each server
    @server_stats = @servers.map do |server|
      metric = server.latest_metric
      {
        server: server,
        metric: metric
      }
    end.select { |s| s[:metric].present? }

    # Calculate totals
    @total_cpu_cores = @server_stats.sum { |s| s[:metric].cpu_cores.to_i }
    @total_memory = @server_stats.sum { |s| s[:metric].memory_total.to_f }
    @used_memory = @server_stats.sum { |s| s[:metric].memory_usage.to_f }
    @total_disk = @server_stats.sum { |s| s[:metric].disk_total.to_f }
    @used_disk = @server_stats.sum { |s| s[:metric].disk_usage.to_f }

    # Calculate averages
    @avg_cpu_usage = @server_stats.any? ? (@server_stats.sum { |s| s[:metric].cpu_usage.to_f } / @server_stats.size) : 0
    @memory_percent = @total_memory > 0 ? (@used_memory / @total_memory * 100) : 0
    @disk_percent = @total_disk > 0 ? (@used_disk / @total_disk * 100) : 0

    # Calculate provider distribution
    @provider_stats = @servers.group(:provider).count
    @provider_stats["未设置"] = @provider_stats.delete(nil) || 0

    # Calculate OS distribution
    @os_stats = @servers.group(:os_name).count
    @os_stats["未知"] = @os_stats.delete(nil) || 0

    # Calculate country/region distribution
    @country_stats = @servers.group(:country_code).count
    @country_stats["未知"] = @country_stats.delete(nil) || 0
  end
end
