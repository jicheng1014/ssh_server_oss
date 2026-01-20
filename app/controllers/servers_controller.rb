class ServersController < ApplicationController
  before_action :set_server, only: %i[show edit update destroy refresh top ps]

  def index
    @servers = Server.includes(:server_metrics).ordered
    @servers = @servers.where(country_code: params[:country]) if params[:country].present?
    @servers = @servers.where(provider: params[:provider]) if params[:provider].present?
    @servers = @servers.where(os_name: params[:os]) if params[:os].present?
    @servers = @servers.where("host LIKE ?", "%#{params[:ip]}%") if params[:ip].present?

    @countries = Server.where.not(country_code: nil).distinct.pluck(:country_code).sort
    @providers = Server.where.not(provider: [ nil, "" ]).distinct.pluck(:provider).sort
    @os_names = Server.where.not(os_name: [ nil, "" ]).distinct.pluck(:os_name).sort

    # 检查是否有全局认证信息配置（如果没有，提示用户去系统设置配置）
    @has_global_auth = SshKeyService.configured?
    # 如果没有全局认证信息，并且有服务器，提示用户配置
    @show_auth_warning = !@has_global_auth && @servers.any?
  end

  def show
    @metrics = @server.server_metrics.order(created_at: :desc).limit(50)
  end

  def new
    @server = Server.new(port: 22)
  end

  def edit
  end

  def create
    @server = Server.new(server_params)
    @server.position = Server.maximum(:position).to_i + 1

    if @server.save
      # 如果服务器是活跃的，立即异步执行一次数据获取
      if @server.active?
        RefreshServerJob.perform_later(@server)
      end
      redirect_to servers_path, notice: "服务器添加成功，正在获取数据..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @server.update(server_params)
        format.html { redirect_to servers_path, notice: "服务器更新成功" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@server, :notes), partial: "servers/notes", locals: { server: @server }) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@server, :notes), partial: "servers/notes", locals: { server: @server }), status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @server.destroy
    redirect_to servers_path, notice: "服务器已删除"
  end

  def refresh
    unless @server.has_authentication?
      redirect_to settings_path, alert: "SSH 认证信息未配置。请先在系统设置中配置 SSH 私钥。"
      return
    end

    begin
      ServerMonitorService.new(@server).call
      redirect_to @server, notice: "刷新成功"
    rescue => e
      if e.message.include?("SSH 认证信息未配置")
        redirect_to settings_path, alert: "SSH 认证信息未配置。请先在系统设置中配置 SSH 私钥。"
      else
        redirect_to @server, alert: "刷新失败: #{e.message}"
      end
    end
  end

  def top
    result = TopCommandService.new(@server).call
    render json: result
  end

  def ps
    format = params[:format] || "aux"
    result = PsCommandService.new(@server, format: format).call
    render json: result
  end

  def refresh_all
    unless SshKeyService.configured?
      redirect_to settings_path, alert: "SSH 认证信息未配置。请先在系统设置中配置 SSH 私钥。"
      return
    end

    Server.active.find_each do |server|
      RefreshServerJob.perform_later(server)
    end

    respond_to do |format|
      format.html { redirect_to servers_path, notice: "正在刷新所有服务器..." }
      format.turbo_stream { head :ok }
    end
  end

  def sort
    params[:positions].each do |id, position|
      Server.where(id: id).update_all(position: position)
    end
    head :ok
  end

  private

  def set_server
    @server = Server.find(params[:id])
  end

  def server_params
    permitted = params.require(:server).permit(:name, :host, :port, :username, :active, :provider, :password, :private_key, :notes)
    # 编辑时，空的密码和私钥不应覆盖现有值
    if action_name == "update"
      permitted.delete(:password) if permitted[:password].blank?
      permitted.delete(:private_key) if permitted[:private_key].blank?
    end
    permitted
  end
end
