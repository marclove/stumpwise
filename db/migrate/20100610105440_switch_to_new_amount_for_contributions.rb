class SwitchToNewAmountForContributions < ActiveRecord::Migration
  def self.up
    remove_column :contributions, :amount
    rename_column :contributions, :new_amount, :amount
  end

  def self.down
    rename_column :contributions, :amount, :new_amount
    add_column :contributions, :amount, :integer
  end
end
