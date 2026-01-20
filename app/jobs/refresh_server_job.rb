class RefreshServerJob < ApplicationJob
  queue_as :default

  def perform(server)
    ServerMonitorService.new(server).call
    Turbo::StreamsChannel.broadcast_replace_to(
      "servers",
      target: "server_#{server.id}",
      partial: "servers/server",
      locals: { server: server.reload }
    )
  end
end
