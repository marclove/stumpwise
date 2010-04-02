class SwitchToCarrierwave < ActiveRecord::Migration
  def self.up
    rename_column :assets, :filename, :file
    remove_column :assets, :content_type
    remove_column :assets, :size
    
    rename_column :theme_assets, :filename, :file
    remove_column :theme_assets, :content_type
    remove_column :theme_assets, :size
  end

  def self.down
    rename_column :assets, :file, :filename
    add_column :assets, :content_type, :string
    add_column :assets, :size, :integer

    rename_column :theme_assets, :file, :filename
    add_column :theme_assets, :content_type, :string
    add_column :theme_assets, :size, :integer
  end
end
