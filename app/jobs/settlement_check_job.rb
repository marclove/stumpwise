class SettlementCheckJob < Struct.new(:transaction_id)
  def perform
    # if not found, raises a Braintree NotFoundError
    transaction = Braintree::Transaction.find(transaction_id)
    
    if transaction.status == "settled"
      contribution = Contribution.first(:conditions => {:transaction_id => transaction_id})
      raise ActiveRecord::RecordNotFound unless contribution
      contribution.settle!
    else
      raise Stumpwise::Transaction::NotSettledError
    end
  end
end