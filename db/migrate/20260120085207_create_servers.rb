class CreateServers < ActiveRecord::Migration[8.1]
  def change
    create_table :servers do |t|
      t.string :name, null: false
      t.string :host, null: false
      t.integer :port, default: 22
      t.string :username, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :servers, :host, unique: true
  end
end
