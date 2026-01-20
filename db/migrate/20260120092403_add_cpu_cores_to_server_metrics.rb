class AddCpuCoresToServerMetrics < ActiveRecord::Migration[8.1]
  def change
    add_column :server_metrics, :cpu_cores, :integer
  end
end
