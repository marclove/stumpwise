# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class WeeklyContributions < ActionMailer::Base
  default :bcc => "statements@stumpwise.com"
  
  def campaign_statement(statement)
    @statement = statement
    mail({:to => statement.site.campaign_email,
          :from => "Stumpwise <support@stumpwise.com>",
          :subject => "Weekly Statement - #{statement.disbursed_on}"})
    
    # recipients  statement.site.campaign_email
    # from        "Stumpwise <support@stumpwise.com>"
    # bcc         "statements@stumpwise.com"
    # subject     "Weekly Statement - #{statement.disbursed_on}"
    # content_type "multipart/alternative"
    # 
    # part :content_type => "text/html",
    #      :body => render_message("campaign_statement.text.html.erb", :statement => statement)
    #       
    # part "text/plain" do |p|
    #   p.body = render_message("campaign_statement.text.plain.erb", :statement => statement)
    #   p.transfer_encoding = "base64"
    # end
  end
  
  def summary_statement(disbursement_date)
    @disbursement_date  = disbursement_date
    @statements         = CampaignStatement.all(:conditions => {:disbursed_on => disbursement_date}, :include => :site)
    @total_raised       = statements.sum(&:total_raised)
    @total_fees         = statements.sum(&:total_fees)
    @total_due          = statements.sum(&:total_due)
    
    mail({:to => "billing@stumpwise.com",
          :from => "billing@stumpwise.com",
          :subject => "Batch Report - #{disbursement_date}"})
    
    # statements = CampaignStatement.all(:conditions => {:disbursed_on => disbursement_date}, :include => :site)
    # 
    # recipients  "billing@stumpwise.com"
    # from        "billing@stumpwise.com"
    # bcc         "statements@stumpwise.com"
    # subject     "Batch Report - #{disbursement_date}"
    # content_type "text/html"
    # body        :disbursement_date => disbursement_date,
    #             :statements => statements,
    #             :total_raised => statements.sum(&:total_raised),
    #             :total_fees => statements.sum(&:total_fees),
    #             :total_due => statements.sum(&:total_due)
  end
end