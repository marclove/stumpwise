class AddTimezones < ActiveRecord::Migration
  def self.up
    add_column :sites, :timezone, :string, :default => "Pacific Time (US & Canada)"
    add_column :users, :timezone, :string, :default => "Pacific Time (US & Canada)"
  end

  def self.down
    remove_column :sites, :timezone, :string
    remove_column :sites, :timezone, :string
  end
end
