class AddSuggestedContributionAmountOption < ActiveRecord::Migration
  def self.up
    add_column :sites, :suggested_contribution_amount, :integer
  end

  def self.down
    remove_column :sites, :suggested_contribution_amount
  end
end
