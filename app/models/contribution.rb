# == Schema Information
# Schema version: 20100316133950
#
# Table name: contributions
#
#  id                      :integer         not null, primary key
#  site_id                 :integer
#  order_id                :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  email                   :string(255)
#  amount                  :integer
#  status                  :string(255)
#  ip                      :string(255)
#  employer                :string(255)
#  occupation              :string(255)
#  compliance_confirmation :boolean
#  compliance_statement    :text
#  first_name              :string(255)
#  last_name               :string(255)
#  card_type               :string(255)
#  card_display_number     :string(255)
#  card_month              :integer
#  card_year               :integer
#  address1                :string(255)
#  address2                :string(255)
#  city                    :string(255)
#  state                   :string(255)
#  country                 :string(255)
#  zip                     :string(255)
#  phone                   :string(255)
#  success                 :boolean
#  test                    :boolean
#  fraud_review            :boolean
#  message                 :text
#  authorization           :string(255)
#  cvv_result              :text
#  avs_result              :text
#

class Contribution < ActiveRecord::Base
  belongs_to :site
  
  attr_accessor :card_number
  attr_accessor :verification_value
  
  def process
    site.gateway.purchase(amount, credit_card, options)
  end
  
  def credit
    site.gateway.credit(amount, authorization, options)
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      :number => card_number,
      :month => card_month,
      :year => card_year,
      :type => card_type,
      :first_name => first_name,
      :last_name => last_name,
      :verification_value => verification_value
    )
  end

  def options
    {
      :order_id => order_id,
      :ip => ip,
      :customer => "#{first_name} #{last_name} <#{email}>",
      :merchant => site.name,
      :description => "Campaign contribution",
      :email => email.to_s,
      :billing_address => {
        :name => "#{first_name} #{last_name}",
        :address1 => address1,
        :address2 => address2,
        :city => city,
        :state => state,
        :country => country,
        :zip => zip,
        :phone => phone
      }
    }
  end
end
