class AddProviderToServers < ActiveRecord::Migration[8.1]
  def change
    add_column :servers, :provider, :string
  end
end
