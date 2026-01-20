class MonitorAllServersService
  def call
    Server.active.find_each do |server|
      ServerMonitorService.new(server).call
    end
  end
end
