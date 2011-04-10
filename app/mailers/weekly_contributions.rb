class WeeklyContributions < ActionMailer::Base
  def campaign_statement(statement)
    recipients  statement.site.campaign_email
    from        "Stumpwise <support@stumpwise.com>"
    bcc         "statements@stumpwise.com"
    subject     "Weekly Statement - #{statement.disbursed_on}"
    content_type "multipart/alternative"
    
    part :content_type => "text/html",
         :body => render_message("campaign_statement.text.html.erb", :statement => statement)
          
    part "text/plain" do |p|
      p.body = render_message("campaign_statement.text.plain.erb", :statement => statement)
      p.transfer_encoding = "base64"
    end
  end
  
  def summary_statement(disbursement_date)
    statements = CampaignStatement.all(:conditions => {:disbursed_on => disbursement_date}, :include => :site)
    
    recipients  "billing@stumpwise.com"
    from        "billing@stumpwise.com"
    bcc         "statements@stumpwise.com"
    subject     "Batch Report - #{disbursement_date}"
    content_type "text/html"
    body        :disbursement_date => disbursement_date,
                :statements => statements,
                :total_raised => statements.sum(&:total_raised),
                :total_fees => statements.sum(&:total_fees),
                :total_due => statements.sum(&:total_due)
  end
end