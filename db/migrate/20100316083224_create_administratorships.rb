class CreateAdministratorships < ActiveRecord::Migration
  def self.up
    create_table :administratorships do |t|
      t.integer :administrator_id
      t.integer :site_id
    end
    add_index :administratorships, [:administrator_id, :site_id], :unique => true
  end

  def self.down
    drop_table :administratorships
  end
end
