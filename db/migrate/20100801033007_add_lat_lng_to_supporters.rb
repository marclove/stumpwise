class AddLatLngToSupporters < ActiveRecord::Migration
  def self.up
    add_column :supporters, :lat, :float
    add_column :supporters, :lng, :float
  end

  def self.down
    remove_column :supporters, :lat
    remove_column :supporters, :lng
  end
end
