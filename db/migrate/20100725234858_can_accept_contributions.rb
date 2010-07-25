class CanAcceptContributions < ActiveRecord::Migration
  def self.up
    add_column :sites, :can_accept_contributions, :boolean, :default => true
    change_column_default :sites, :can_accept_contributions, false
  end

  def self.down
    remove_column :sites, :can_accept_contributions
  end
end
