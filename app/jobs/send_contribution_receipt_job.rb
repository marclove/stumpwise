class SendContributionReceiptJob < Struct.new(:contribution_id)
  def perform
    ContributionNotifier.send_receipt(Contribution.find(contribution_id))
  end
end