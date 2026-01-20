class CreateServerMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :server_metrics do |t|
      t.references :server, null: false, foreign_key: true
      t.float :cpu_usage
      t.float :memory_usage
      t.float :memory_total
      t.float :disk_usage
      t.float :disk_total

      t.timestamps
    end
  end
end
