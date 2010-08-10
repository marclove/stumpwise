class SwitchToMongoDbThemes < ActiveRecord::Migration
  def self.up
    add_column :sites, :mongo_theme_id, :string
    add_column :sites, :mongo_theme_version_id, :string
    add_column :sites, :mongo_theme_customization_id, :string
    add_index :sites, :mongo_theme_id
    add_index :sites, :mongo_theme_version_id
  end

  def self.down
    drop_index :sites, :mongo_theme_id
    drop_index :sites, :mongo_theme_version_id
    remove_column :sites, :mongo_theme_id
    remove_column :sites, :mongo_theme_version_id
    remove_column :sites, :mongo_theme_customization_id
  end
end
