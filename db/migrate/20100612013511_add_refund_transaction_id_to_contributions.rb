class AddRefundTransactionIdToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :refund_transaction_id, :string, :limit => 10
  end

  def self.down
    remove_column :contributions, :refund_transaction_id
  end
end
