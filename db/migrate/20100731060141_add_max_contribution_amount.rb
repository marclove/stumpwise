class AddMaxContributionAmount < ActiveRecord::Migration
  def self.up
    add_column :sites, :max_contribution_amount, :integer
    Site.reset_column_information
    Site.all.each{|s| s.update_attribute(:max_contribution_amount, 250)}
  end

  def self.down
    remove_column :sites, :max_contribution_amount
  end
end
