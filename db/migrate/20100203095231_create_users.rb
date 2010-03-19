class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :email,               :null => false
      t.string    :first_name
      t.string    :last_name
      t.string    :crypted_password
      t.string    :password_salt
      t.string    :persistence_token,   :null => false
      t.string    :single_access_token
      t.string    :perishable_token
      t.timestamps
      t.integer   :login_count,         :null => false, :default => 0
      t.integer   :failed_login_count,  :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip
      
    end
    add_index :users, :email, :unique => true
    add_index :users, :persistence_token
    add_index :users, :single_access_token
    add_index :users, :perishable_token
    
    add_column :sites, :owner_id, :integer
  end

  def self.down
    drop_column :sites, :owner_id
    drop_table :users
  end
end
