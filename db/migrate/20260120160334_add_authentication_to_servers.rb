class AddAuthenticationToServers < ActiveRecord::Migration[8.1]
  def change
    add_column :servers, :password, :text
    add_column :servers, :private_key, :text
  end
end
