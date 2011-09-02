class WelcomeEmail < ActionMailer::Base
  def welcome_email(site)
    @site = site
    mail({:to => site.campaign_email,
          :from => "Stumpwise <support@stumpwise.com>",
          :subject => "Welcome to Stumpwise!"})

    # recipients  site.campaign_email
    # from        "Stumpwise <support@stumpwise.com>"
    # subject     "Welcome to Stumpwise!"
    # body        :site => site
  end
end