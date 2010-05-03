# == Schema Information
# Schema version: 20100426155751
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
  has_many :transactions, :class_name => 'ContributionTransaction',
                          :dependent => :destroy
  
  named_scope :pending,   :conditions => {:status => 'pending'}
  named_scope :approved,  :conditions => {:status => 'approved'}
  named_scope :declined,  :conditions => {:status => 'declined'}
  named_scope :refunded,  :conditions => {:status => 'refunded'}
  
  validates_presence_of     :site_id
  validates_length_of       :email, :within => 6..100, :allow_blank => false
  validates_format_of       :email, :with => RegEmailOk, :allow_blank => false
  validates_numericality_of :amount, :greater_than => 100, :only_integer => true
  validates_presence_of     :first_name, :last_name, :address1, :city, :state,
                            :zip, :country, :occupation, :employer
  validates_acceptance_of   :compliance_confirmation, :accept => true,
                            :if => :requires_compliance_confirmation?
  

  include AASM
  aasm_column :status
  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :approved, :enter => :send_receipt
  aasm_state :declined
  aasm_state :refunded

  aasm_event :contribution_approved do
    transitions :from => :pending, :to => :approved
  end

  aasm_event :contribution_declined do
    transitions :from => [:pending, :declined], :to => :declined
  end

  aasm_event :contribution_refunded do
    transitions :from => [:approved, :refunded], :to => :refunded
  end
  
  
  def process(credit_card, options = default_options)
    update_attributes(
      :order_id => ActiveMerchant::Utils.generate_unique_id,
      :card_type => credit_card.type,
      :card_display_number => credit_card.display_number,
      :compliance_statement => site.eligibility_statement,
      :card_year => credit_card.year,
      :card_month => credit_card.month,
      :test => (ActiveMerchant::Billing::Base.mode == :test)
    )
    transaction do
      authorization = ContributionTransaction.approve(amount, credit_card, options)
      transactions.push(authorization)
      authorization.success? ? contribution_approved! : contribution_declined!
      authorization
    end
  end
  
  def refund(options = {})
    transaction do
      authorization = ContributionTransaction.refund(amount, authorization_reference, options)
      transactions.push(authorization)
      contribution_refunded! if authorization.success?
      authorization
    end
  end
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end

  def authorization_reference
    if authorization = transactions.find_by_action_and_success('approve', true, :order => 'id ASC')
      authorization.reference
    end
  end
  
  def display_amount
    amount.to_f / 100.0
  end
  
  def contributor_name
    "#{first_name} #{last_name}"
  end
  
  def contributor_name_with_email
    "#{contributor_name} <#{email}>"
  end
  
  def card_information
    "#{card_type.titlecase} #{card_display_number}"
  end
  
  def default_options
    {
      :order_id => order_id,
      :ip => ip,
      :customer => contributor_name_with_email,
      :merchant => site.campaign_legal_name,
      :description => "Campaign contribution",
      :email => email,
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
  
  def send_receipt
    ContributionNotifier.deliver_send_receipt(self)
  end
  handle_asynchronously :send_receipt
  
  private
    def requires_compliance_confirmation?
      return false unless site
      !site.eligibility_statement.blank?
    end
end
