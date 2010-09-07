# == Schema Information
# Schema version: 20100825194538
#
# Table name: contributions
#
#  id                      :integer(4)      not null, primary key
#  site_id                 :integer(4)
#  order_id                :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  email                   :string(255)
#  status                  :string(255)
#  ip                      :string(255)
#  employer                :string(255)
#  occupation              :string(255)
#  compliance_confirmation :boolean(1)
#  compliance_statement    :text
#  first_name              :string(255)
#  last_name               :string(255)
#  card_type               :string(255)
#  card_display_number     :string(255)
#  card_month              :integer(4)
#  card_year               :integer(4)
#  address1                :string(255)
#  address2                :string(255)
#  city                    :string(255)
#  state                   :string(255)
#  country                 :string(255)
#  zip                     :string(255)
#  phone                   :string(255)
#  test                    :boolean(1)
#  amount                  :decimal(8, 2)   default(0.0)
#  processing_fees         :decimal(8, 2)   default(0.0)
#  net_amount              :decimal(8, 2)   default(0.0)
#  transaction_id          :string(10)
#  refund_transaction_id   :string(10)
#  legacy                  :boolean(1)
#

require 'digest/md5'

class Contribution < ActiveRecord::Base
  attr_reader :transaction_result

  belongs_to :site
  has_many :transactions, :class_name => 'ContributionTransaction',
                          :dependent => :destroy
  
  validates_presence_of     :site_id
  validates_length_of       :email, :within => 6..100, :allow_blank => false
  validates_format_of       :email, :with => RegEmailOk, :allow_blank => false
  validates_numericality_of :amount, :greater_than => 0.99
  validates_presence_of     :first_name, :last_name, :address1, :city, :state,
                            :zip, :country, :occupation, :employer
  validates_acceptance_of   :compliance_confirmation, :accept => true,
                            :if => :requires_compliance_confirmation?
  
  named_scope :raised, :conditions => 'contributions.status IN ("approved", "settled", "paid")'
  
  include AASM
  aasm_column :status
  aasm_initial_state :pending
  
  aasm_state :pending,  :enter => :prepare
  aasm_state :approved
  aasm_state :declined
  aasm_state :voided
  aasm_state :settled
  aasm_state :refunded
  aasm_state :paid
  
  aasm_event :approve, :before => :increment_processing_fees, :success => [:send_receipt, :schedule_settlement_check], :error => :decline do
    transitions :from => :pending, :to => :approved, :on_transition => :process_approval
  end
  
  aasm_event :void, :before => :increment_processing_fees do
    transitions :from => :approved, :to => :voided, :on_transition => :process_void, :guard => :voidable?
  end
  
  aasm_event :settle, :after => :add_amount_to_net do
    transitions :from => :approved, :to => :settled, :guard => :settleable?
  end
  
  aasm_event :refund, :before => :increment_processing_fees, :after => :subtract_amount_from_net do
    transitions :from => :settled, :to => :refunded, :on_transition => :process_refund, :guard => :refundable?
  end
  
  aasm_event :payout do
    transitions :from => :settled, :to => :paid
  end
  
  def reversible?
    return false unless (approved? || settled?) # local check
    voidable? || refundable? # remote check
  end
  
  def reverse
    unless (approved? || settled?)
      raise Stumpwise::Transaction::ReversalError, "This transaction is #{status} and cannot be reversed."
    end
    
    if voidable?
      void!
    elsif refundable?
      settle! if approved? # settled remotely, but we haven't settled it locally yet
      refund! if settled? # don't refund it unless we successfully settled it locally
    else
      raise Stumpwise::Transaction::ReversalError, "This transaction's status is currently \"#{remote_status.gsub('_',' ')}\" and cannot be reversed."
    end
  end
  
  # A guard method to double check with the gateway that this contribution can
  # still be voided.
  def voidable?
    ["authorized","submitted_for_settlement"].include?(remote_status)
  end
  
  # A guard method to check if the transaction has been settled on the gateway.
  def settleable?
    remote_status == "settled"
  end
  
  # A guard method to double check with the gateway that this contribution can
  # still be refunded.
  def refundable?
    remote_status == "settled"
  end
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end
  
  def contributor_name
    "#{first_name} #{last_name}"
  end
  
  def contributor_name_with_email
    "#{contributor_name} <#{email}>"
  end
  
  def card_information
    "#{card_type.titlecase if card_type} #{card_display_number}"
  end
  
  # 5% + 0.50
  def transaction_processing_fee
    @transaction_processing_fee ||= (amount.quo(20).round(2) + BigDecimal("0.50"))
  end
  
  def transaction_errors
    if transaction_result
      errors = []
      if transaction_result.respond_to?(:errors)
        transaction_result.errors.each{ |e| errors << "(#{e.code}) #{e.message}" }
      end
      if transaction_result.respond_to?(:transaction) && transaction_result.transaction.respond_to?(:processor_response_text)
        errors << transaction_result.transaction.processor_response_text if transaction_result.transaction.processor_response_text.present?
      end
      errors.join(", ") if errors.present?
    else
      nil
    end
  end
  
  # Error callback for the #approve state event.
  # Should be a private method, but AASM is broken and waiting for my commit to be pulled.
  def decline(errors)
    if pending?
      update_attribute(:status, 'declined')
    else
      raise errors
    end
  end
  
  private
    def prepare
      self.order_id = generate_unique_id
      self.test     = (Braintree::Configuration.environment != :production)
    end
    
    # Submits the transaction to the gateway for approval. Raises an error if
    # the gateway declines the transaction, passing along the gateway's error
    # messages.
    def process_approval(credit_card)
      @transaction_result = Braintree::Transaction.sale(
        :amount      => amount,
        :order_id    => order_id,
        :credit_card => credit_card,
        :options     => {:submit_for_settlement => true}
      )
      # record the communication with the gateway
      if transaction_result.success?
        record_approval(transaction_result.transaction)
        record_gateway_success 'approve', transaction_result.transaction.id
      else
        record_gateway_failure 'approve', transaction_errors
        raise Stumpwise::Transaction::RejectedError, transaction_errors
      end
    end
    
    def process_void
      @transaction_result = remote_transaction.void
      if transaction_result.success?
        record_gateway_success 'void', transaction_result.transaction.id
      else
        record_gateway_failure 'void', transaction_errors
        raise Stumpwise::Transaction::RejectedError, transaction_errors
      end
    end
    
    def process_refund
      @transaction_result = remote_transaction.refund
      if transaction_result.success?
        update_attribute(:refund_transaction_id, transaction_result.new_transaction.id)
        record_gateway_success 'refund', transaction_result.new_transaction.id
      else
        record_gateway_failure 'refund', transaction_errors
        raise Stumpwise::Transaction::RejectedError, transaction_errors
      end
    end
    
    def record_gateway_success(action, reference)
      transactions.create(
        :action => action,
        :amount => amount,
        :success => true,
        :reference => reference
      )
    end
    
    def record_gateway_failure(action, errors)
      transactions.create(
        :action => action,
        :amount => amount,
        :success => false,
        :message => errors
      )
    end
    
    def record_approval(transaction)
      update_attributes(
        :transaction_id       => transaction.id,
        :card_type            => transaction.credit_card_details.card_type,
        :card_display_number  => transaction.credit_card_details.masked_number,
        :card_month           => transaction.credit_card_details.expiration_month,
        :card_year            => transaction.credit_card_details.expiration_year,
        :compliance_statement => (compliance_confirmation? ? site.eligibility_statement : nil)
      )
    end
    
    def send_receipt
      ContributionNotifier.deliver_send_receipt(self)
    end
    
    def schedule_settlement_check
      Delayed::Job.enqueue(SettlementCheckJob.new(self.id), 0, 24.hours.from_now.getutc)
    end
    
    # Increment's the Contribution's processing fees by 1 transaction. This
    # allows us to easily add to the processing fees each time a transaction
    # is submitted to the gateway.
    def increment_processing_fees
      increment(:processing_fees, transaction_processing_fee)
      decrement(:net_amount, transaction_processing_fee)
      save!
    end
    
    # We only add the transaction amount to the net_amount after the
    # transaction has been settled and we know we'll be collecting the money.
    def add_amount_to_net
      increment(:net_amount, amount)
      save!
    end
    
    def subtract_amount_from_net
      decrement(:net_amount, amount)
      save!
    end
    
    def requires_compliance_confirmation?
      return false unless site
      !site.eligibility_statement.blank?
    end
    
    def generate_unique_id
      md5 = Digest::MD5.new
      now = Time.now
      md5 << now.to_s
      md5 << String(now.usec)
      md5 << String(rand(0))
      md5 << String($$)
      md5 << self.class.name
      md5.hexdigest
    end
    
    def remote_transaction
      begin
        return nil unless transaction_id
        @remote_transaction ||= Braintree::Transaction.find(transaction_id)
      rescue Braintree::NotFoundError
        return nil
      end
    end
    
    def remote_status
      remote_transaction ? remote_transaction.status : ''
    end
end
