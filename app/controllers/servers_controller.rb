class ServersController < ApplicationController
  before_action :set_server, only: %i[show edit update destroy refresh]

  def index
    @servers = Server.includes(:server_metrics).ordered
    @servers = @servers.where(country_code: params[:country]) if params[:country].present?
    @servers = @servers.where(provider: params[:provider]) if params[:provider].present?
    @servers = @servers.where(os_name: params[:os]) if params[:os].present?
    @servers = @servers.where("host LIKE ?", "%#{params[:ip]}%") if params[:ip].present?

    @countries = Server.where.not(country_code: nil).distinct.pluck(:country_code).sort
    @providers = Server.where.not(provider: [nil, ""]).distinct.pluck(:provider).sort
    @os_names = Server.where.not(os_name: [nil, ""]).distinct.pluck(:os_name).sort
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
      redirect_to servers_path, notice: "服务器添加成功"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @server.update(server_params)
      redirect_to servers_path, notice: "服务器更新成功"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @server.destroy
    redirect_to servers_path, notice: "服务器已删除"
  end

  def refresh
    ServerMonitorService.new(@server).call
    redirect_to @server, notice: "刷新成功"
  end

  def refresh_all
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
    params.require(:server).permit(:name, :host, :port, :username, :active, :provider)
  end
end
