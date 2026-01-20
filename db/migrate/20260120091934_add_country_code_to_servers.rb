class AddCountryCodeToServers < ActiveRecord::Migration[8.1]
  def change
    add_column :servers, :country_code, :string
  end
end
