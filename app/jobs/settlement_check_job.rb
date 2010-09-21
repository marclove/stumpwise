class SettlementCheckJob < Struct.new(:contribution_id)
  def perform
    @contribution = Contribution.find(contribution_id)
    transaction = Braintree::Transaction.find(@contribution.transaction_id)
    
    if @contribution.approved? # don't do anything if it's been voided or refunded
      if transaction.status == 'settled'
        @contribution.increment(:net_amount, @contribution.amount)  # add_amount_to_net
        @contribution.status = 'settled'                            # mark as settled
        @contribution.save!
      else
        raise Stumpwise::Transaction::NotSettledError
      end
    end
  end
end