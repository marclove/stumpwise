# == Schema Information
# Schema version: 20100720222608
#
# Table name: sms_messages
#
#  id              :integer(4)      not null, primary key
#  sms_campaign_id :integer(4)
#  recipient_id    :integer(4)
#

class SmsMessage < ActiveRecord::Base
  belongs_to :sms_campaign, :counter_cache => :recipients_count
  belongs_to :recipient, :class_name => "Supporter"
  
  after_create :send_message
  
  private
    def send_message
      unless recipient.mobile_phone.blank?
        Twilio::Sms.message('4154831721', recipient.mobile_phone, sms_campaign.message)
      end
    end
end
