class AddSubscriptionDetailsToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :active, :boolean, :default => true
    add_column :sites, :credit_card_token, :string
    add_column :sites, :credit_card_expiration, :datetime
    add_column :sites, :subscription_id, :string
    add_column :sites, :subscription_billing_cycle, :integer
    change_column_default :sites, :active, false
  end

  def self.down
    remove_column :sites, :active
    remove_column :sites, :credit_card_token
    remove_column :sites, :credit_card_expiration
    remove_column :sites, :subscription_id
    remove_column :sites, :subscription_billing_cycle
  end
end
