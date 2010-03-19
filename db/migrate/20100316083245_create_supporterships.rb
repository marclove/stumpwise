class CreateSupporterships < ActiveRecord::Migration
  def self.up
    create_table :supporterships do |t|
      t.integer   :supporter_id
      t.integer   :site_id
      t.boolean   :receive_email
    end
    add_index :supporterships, [:supporter_id, :site_id], :unique => true
  end

  def self.down
    drop_table :supporterships
  end
end
