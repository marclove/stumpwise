class ImproveIndexesOnItems < ActiveRecord::Migration
  def self.up
    remove_index :items, :column => [:lft, :rgt, :parent_id, :site_id]
    
    add_index :items, [:parent_id, :published, :type, :lft], :name => :by_parent_published_type_and_lft
    
    remove_index :items, :column => [:parent_id, :site_id]
    add_index :items, [:site_id, :parent_id, :published, :show_in_navigation], :name => :by_site_parent_published_and_nav
    
    remove_index :items, :column => [:site_id, :published, :permalink]
    add_index :items, [:permalink, :site_id, :published], :name => :by_permalink_site_and_published
  end

  def self.down
    add_index :items, [:lft, :rgt, :parent_id, :site_id]
    
    remove_index :items, :name => :by_parent_published_type_and_lft
    
    add_index :items, [:parent_id, :site_id]
    remove_index :items, :name => :by_site_parent_published_and_nav
    
    add_index :items, [:site_id, :published, :permalink]
    remove_index :items, :name => :by_permalink_site_and_published
  end
end
