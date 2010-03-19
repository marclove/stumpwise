class CreateSupporters < ActiveRecord::Migration
  def self.up
    create_table :supporters do |t|
      t.timestamps
      t.string    :email, :null => false
      t.string    :name_prefix
      t.string    :first_name
      t.string    :last_name
      t.string    :name_suffix
      t.string    :phone
      t.string    :thoroughfare
      t.string    :locality
      t.string    :subadministrative_area
      t.string    :administrative_area
      t.string    :country
      t.string    :postal_code
    end
    add_index :supporters, :email, :unique => true
    add_index :supporters, [:last_name, :first_name]
  end

  def self.down
    drop_table :supporters
  end
end
