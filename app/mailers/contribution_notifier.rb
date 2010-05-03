class ContributionNotifier < ActionMailer::Base
  def send_receipt(contribution)
    recipients  contribution.contributor_name_with_email
    from        "#{contribution.site.name} no-reply@stumpwise.com"
    subject     "Contribution Receipt"
    body        :contribution => contribution
  end
end