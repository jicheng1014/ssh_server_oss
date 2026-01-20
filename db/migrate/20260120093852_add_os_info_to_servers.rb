class AddOsInfoToServers < ActiveRecord::Migration[8.1]
  def change
    add_column :servers, :os_name, :string
    add_column :servers, :os_version, :string
    add_column :servers, :kernel_version, :string
  end
end
