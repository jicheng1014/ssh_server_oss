class MonitorServersJob < ApplicationJob
  queue_as :default

  def perform
    MonitorAllServersService.new.call
  end
end
