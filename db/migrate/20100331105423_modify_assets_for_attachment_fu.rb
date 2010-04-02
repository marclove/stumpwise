class ModifyAssetsForAttachmentFu < ActiveRecord::Migration
  def self.up
    rename_column :assets, :photo_file_name, :filename
    rename_column :assets, :photo_content_type, :content_type
    rename_column :assets, :photo_file_size, :size
    change_column :assets, :site_id, :integer, :limit => nil
  end

  def self.down
    change_column :assets, :site_id, :string
    rename_column :assets, :filename, :photo_file_name
    rename_column :assets, :content_type, :photo_content_type
    rename_column :assets, :size, :photo_file_size
  end
end
