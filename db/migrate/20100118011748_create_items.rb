class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.timestamps
      t.string  :type
      t.integer :created_by
      t.integer :updated_by
      
      # acts_as_nested_set
      t.integer :site_id
      t.integer :parent_id
      t.integer :lft, :rgt

      t.string  :title
      t.string  :slug
      t.string  :permalink
      t.boolean :published, :default => false
      t.boolean :show_in_navigation, :default => false
      t.string  :template_name
    end
    
    add_index :items, [:site_id, :published, :permalink]
    add_index :items, [:parent_id, :site_id]
    add_index :items, [:lft, :rgt, :parent_id, :site_id]
  end

  def self.down
    drop_table :items
  end
end
