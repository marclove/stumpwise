class SendContributionReceiptJob < Struct.new(:contribution_id)
  ContributionNotifier.deliver_send_receipt(Contribution.find(contribution_id))
end