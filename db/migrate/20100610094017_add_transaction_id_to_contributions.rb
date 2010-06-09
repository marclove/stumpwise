class AddTransactionIdToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :transaction_id, :string, :limit => 10
  end

  def self.down
    remove_column :contributions, :transaction_id
  end
end
