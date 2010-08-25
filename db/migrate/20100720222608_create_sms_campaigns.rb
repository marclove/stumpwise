class CreateSmsCampaigns < ActiveRecord::Migration
  def self.up
    create_table :sms_campaigns do |t|
      t.integer   :site_id
      t.integer   :created_by
      t.datetime  :created_at
      t.string    :status
      t.string    :message
      t.integer   :recipients_count, :default => 0
    end
    
    create_table :sms_messages do |t|
      t.integer :sms_campaign_id, :recipient_id
    end
  end

  def self.down
    drop_table :sms_campaigns
    drop_table :sms_messages
  end
end
