class CreateThemeAssets < ActiveRecord::Migration
  def self.up
    create_table :theme_assets do |t|
      t.integer :theme_id
      t.string  :filename, :content_type
      t.integer :size
    end
  end

  def self.down
    drop_table :theme_assets
  end
end
