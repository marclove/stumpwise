class AddEligibilityStatementToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :eligibility_statement, :text
  end

  def self.down
    remove_column :sites, :eligibility_statement
  end
end
