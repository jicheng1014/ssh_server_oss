class AddLastErrorToServers < ActiveRecord::Migration[8.1]
  def change
    add_column :servers, :last_error, :text
    add_column :servers, :last_checked_at, :datetime
  end
end
