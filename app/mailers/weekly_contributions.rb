class WeeklyContributions < ActionMailer::Base
  def campaign_statement(statement)
    recipients  statement.site.campaign_email
    from        "Stumpwise <support@stumpwise.com>"
    bcc         "statements@stumpwise.com"
    subject     "Weekly Statement - #{statement.disbursed_on}"
    body        :statement => statement
  end
  
  def summary_statement(disbursement_date)
    statements = CampaignStatement.all(:conditions => {:disbursed_on => disbursement_date}, :include => :site)
    
    recipients  "billing@stumpwise.com"
    from        "billing@stumpwise.com"
    bcc         "statements@stumpwise.com"
    subject     "Batch Report - #{disbursement_date}"
    body        :disbursement_date => disbursement_date,
                :statements => statements,
                :total_raised => statements.sum(&:total_raised),
                :total_fees => statements.sum(&:total_fees),
                :total_due => statements.sum(&:total_due)
  end
end