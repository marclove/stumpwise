class ExpandFacebookPageIdField < ActiveRecord::Migration
  def self.up
    change_column :sites, :facebook_page_id, :string, :limit => nil
  end

  def self.down
    change_column :sites, :facebook_page_id, :string, :limit => 50
  end
end
