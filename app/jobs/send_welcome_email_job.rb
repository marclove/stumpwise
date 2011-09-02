class SendWelcomeEmailJob < Struct.new(:site_id)
  def perform
    WelcomeEmail.welcome_email(Site.find(site_id))
  end
end