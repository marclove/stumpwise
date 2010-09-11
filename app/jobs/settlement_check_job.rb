class SettlementCheckJob < Struct.new(:contribution_id)
  def perform
    @contribution = Contribution.find(contribution_id)
    puts "Contribution: #{@contribution.inspect}"
    transaction = Braintree::Transaction.find(@contribution.transaction_id)
    puts "Transaction: #{transaction.inspect}"
    
    if transaction.status == 'settled'
      @contribution.increment(:net_amount, @contribution.amount)  # add_amount_to_net
      @contribution.status = 'settled'                            # mark as settled
      @contribution.save!
    else
      raise Stumpwise::Transaction::NotSettledError
    end
  end
end