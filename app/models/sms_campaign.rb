# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# == Schema Information
# Schema version: 20100916062732
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
