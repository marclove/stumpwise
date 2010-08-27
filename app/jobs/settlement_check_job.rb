class SettlementCheckJob < Struct.new(:contribution_id)
  def perform
    @contribution = Contribution.find(contribution_id)
    unless @contribution.settle!
      raise Stumpwise::Transaction::NotSettledError
    end
  end
end