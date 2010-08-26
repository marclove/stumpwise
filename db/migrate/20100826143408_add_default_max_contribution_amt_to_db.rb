class AddDefaultMaxContributionAmtToDb < ActiveRecord::Migration
  def self.up
    change_column_default :sites, :max_contribution_amount, 2400
  end

  def self.down
  end
end
