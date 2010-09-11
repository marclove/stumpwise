class SettlementCheckJob < Struct.new(:contribution_id)
  def perform
    @contribution = Contribution.find(contribution_id)
    transaction = Braintree::Transaction.find(@contribution.transaction_id)
    
    if transaction.status == 'settled'
      @contribution.increment(:net_amount, amount)            # add_amount_to_net
      @contribution.update_attributes(:status => 'settled')   # mark as settled
    else
      raise Stumpwise::Transaction::NotSettledError
    end
  end
end