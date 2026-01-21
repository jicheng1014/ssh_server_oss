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
  rescue => e
    # 错误信息已经保存在 server.last_error 中
    # 重新加载服务器以获取最新的错误信息，然后广播更新
    server.reload
    Turbo::StreamsChannel.broadcast_replace_to(
      "servers",
      target: "server_#{server.id}",
      partial: "servers/server",
      locals: { server: server }
    )
    # 不重新抛出异常，因为错误信息已经记录在数据库中
    # 任务标记为成功完成，避免任务队列中积累失败任务
  end
end
