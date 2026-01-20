class CreateSystemPrivateKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :system_private_keys do |t|
      t.text :private_key

      t.timestamps
    end
  end
end
