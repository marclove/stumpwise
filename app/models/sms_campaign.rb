# == Schema Information
# Schema version: 20100817131545
#
# Table name: sms_campaigns
#
#  id               :integer(4)      not null, primary key
#  site_id          :integer(4)
#  created_by       :integer(4)
#  created_at       :datetime
#  status           :string(255)
#  message          :string(255)
#  recipients_count :integer(4)      default(0)
#

class SmsCampaign < ActiveRecord::Base
  COST_PER_SMS = BigDecimal('0.05')

  belongs_to :site
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  has_many   :sms_messages
  has_many   :recipients, :through => :sms_messages
  
  validates_length_of :message, :within => 1..160
  validates_numericality_of :recipients_count, :only_integer => true
  
  include AASM
  aasm_column :status
  aasm_initial_state :draft
  aasm_state :draft
  aasm_state :sent
  aasm_event :send_campaign, :success => :settle_payment, :error => :void_payment do
    transitions :from => :draft, :to => :sent, :on_transition => [:authorize_payment, :queue_messages], :guard => :valid_payment_method_on_file?
  end
  
  before_create :set_creator
  
  def authorize_payment
    true
  end
  
  def settle_payment
    true
  end
  
  def void_payment(e)
    puts e
    true
  end
  
  def queue_messages
    site.supporters.wanting_sms.each do |supporter|
      SmsMessage.create!(:sms_campaign => self, :recipient => supporter)
    end
  end
  
  def valid_payment_method_on_file?
    site.valid_payment_method_on_file?
  end
  
  def cost
    if sent?
      sms_messages.count * COST_PER_SMS
    else
      site.supporters.wanting_sms.count * COST_PER_SMS
    end
  end

  private
    def set_creator
      self.creator = Thread.current['user']
    end
end
