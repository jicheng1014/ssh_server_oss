class AddPositionToServers < ActiveRecord::Migration[8.1]
  def change
    add_column :servers, :position, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE servers SET position = id WHERE position = 0
        SQL
      end
    end
  end
end
