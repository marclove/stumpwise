class AddEmailListFieldsToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :campaign_monitor_password, :string
    add_column :sites, :supporter_list_id, :string
    add_column :sites, :contributor_list_id, :string
  end

  def self.down
    remove_column :sites, :campaign_monitor_password
    remove_column :sites, :supporter_list_id
    remove_column :sites, :contributor_list_id
  end
end
