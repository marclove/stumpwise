class SendWelcomeEmailJob < Struct.new(:site_id)
  def perform
    WelcomeEmail.deliver_welcome_email(Site.find(site_id))
  end
end