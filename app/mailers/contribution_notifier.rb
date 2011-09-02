class ContributionNotifier < ActionMailer::Base
  def send_receipt(contribution)
    @contribution = contribution
    mail({
      :to => contribution.contributor_name_with_email,
      :from => "#{contribution.site.name} <no-reply@stumpwise.com>",
      :subject => "Contribution Receipt"
    })
    
    # recipients  contribution.contributor_name_with_email
    # from        "#{contribution.site.name} <no-reply@stumpwise.com>"
    # subject     "Contribution Receipt"
    # content_type "multipart/alternative"
    # 
    # part :content_type => "text/html",
    #      :body => render_message("send_receipt.text.html.erb", :contribution => contribution)
    #       
    # part "text/plain" do |p|
    #   p.body = render_message("send_receipt.text.plain.erb", :contribution => contribution)
    #   p.transfer_encoding = "base64"
    # end
  end
end