class AddContactInfoFieldsToSites < ActiveRecord::Migration
  def self.up
    change_table :sites do |t|
      t.string :campaign_legal_name
      t.string :campaign_street
      t.string :campaign_city
      t.string :campaign_state
      t.string :campaign_zip
      t.rename :public_phone, :campaign_phone
      t.rename :public_email, :campaign_email
    end
  end

  def self.down
    change_table :sites do |t|
      t.remove :campaign_legal_name
      t.remove :campaign_street
      t.remove :campaign_city
      t.remove :campaign_state
      t.remove :campaign_zip
      t.rename :campaign_phone, :public_phone
      t.rename :campaign_email, :public_email
    end
  end
end
