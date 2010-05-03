class AddCampaignTermsOfUseFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :accepted_campaign_terms, :boolean, :default => false
  end

  def self.down
    remove_column :users, :accepted_campaign_terms
  end
end
