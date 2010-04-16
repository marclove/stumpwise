# == Schema Information
# Schema version: 20100415090246
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
  
  named_scope :processed,   :conditions => {:status => 'Processed'}
  named_scope :rejected,    :conditions => {:status => 'Rejected'}
  named_scope :unprocessed, :conditions => {:status => 'Unprocessed'}
  
  RegEmailName   = '[\w\.%\+\-]+'
  RegDomainHead  = '(?:[A-Z0-9\-]+\.)+'
  RegDomainTLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RegEmailOk     = /\A#{RegEmailName}@#{RegDomainHead}#{RegDomainTLD}\z/i
  
  validates_presence_of     :order_id
  validates_length_of       :email, :within => 6..100, :allow_blank => false
  validates_format_of       :email, :with => RegEmailOk, :allow_blank => false
  validates_numericality_of :amount, :greater_than => 100
  validates_inclusion_of    :card_month, :in => 1..12
  validates_numericality_of :card_year, :only_integer => true
  validates_presence_of     :address1
  validates_presence_of     :city
  validates_presence_of     :state
  validates_presence_of     :zip
  validates_presence_of     :country
  validates_presence_of     :occupation
  validates_presence_of     :employer
  validates_inclusion_of    :success, :in => [true, false]
  validates_inclusion_of    :test, :in => [true, false]
  validates_inclusion_of    :fraud_review, :in => [true, false]
  validates_acceptance_of   :compliance_confirmation, :if => :requires_compliance_confirmation?
  
  before_validation_on_create :set_defaults
  before_validation_on_create :store_card_number
  after_validation_on_create  :store_compliance_statement
  #after_save :create_supporter
  
  attr_accessor :card_number
  attr_accessor :verification_value
  
  serialize :avs_result
  serialize :cvv_result
  
  def process
    result = site.gateway.purchase(amount, credit_card, options)
    update_attributes(
      :status => result.success? ? "Processed" : "Rejected",
      :success => result.success?,
      :test => result.test?,
      :authorization => result.authorization,
      :fraud_review => result.fraud_review?,
      :avs_result => result.avs_result,
      :cvv_result => result.cvv_result,
      :message => result.message
    )
    result
  end
  
  def refund
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
  
  private
    def requires_compliance_confirmation?
      return false unless site
      !site.eligibility_statement.blank?
    end
    
    def store_compliance_statement
      if requires_compliance_confirmation?
        self.compliance_statement = site.eligibility_statement
      else
        return true
      end
    end
    
    def store_card_number
      self.card_display_number = self.credit_card.display_number
      return true
    end
    
    def set_defaults
      self.status = "Unprocessed"
      self.order_id = ActiveMerchant::Utils.generate_unique_id
      self.success = false
      self.test = ActiveMerchant::Billing::Base.mode == :test
      self.fraud_review = false
      return true
    end
    
    def create_supporter
      thoroughfare = "#{address1}"
      thoroughfare << ", #{address2}" if !address2.blank?
      site.supporters.create(
        :first_name => first_name,
        :last_name => last_name,
        :email => email,
        :phone => phone,
        :thoroughfare => thoroughfare,
        :locality => city,
        :administrative_area => state,
        :country => country,
        :postal_code => zip
      )
    end
end
