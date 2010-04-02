require 'uuidtools'

class SiteObserver < ActiveRecord::Observer
  observe :site
  
  def after_create(site)
    if create_client(site)
      create_supporter_list(site)
      create_contributor_list(site)
    end
  end
  
  private
    def create_client(site)
      site.update_attribute(:campaign_monitor_password, UUIDTools::UUID.random_create.to_s[0..7])
      @client = CampaignMonitor::Client.new(
        "CompanyName"   => site.name,
        "ContactName"   => site.owner.name,
        "EmailAddress"  => site.public_email,
        "Country"       => "United States of America",
        "Timezone"      => "(GMT-08:00) Pacific Time (US & Canada)" #CM.timezones.select{|t| t =~ Regexp.new(Regexp.escape("Pacific Time (US & Canada)"))}.first
      )
      @client.Create
      @client["Username"] = site.subdomain
      @client["Password"] = site.campaign_monitor_password
      @client["AccessLevel"] = 47
      @client["BillingType"] = "ClientPaysWithMarkup"
      @client["Currency"] = "USD"
      @client["DeliveryFee"] = "20.0"
      @client["CostPerRecipient"] = "1.0"
      @client["DesignAndSpamTestFee"] = "5.0"
      @client.UpdateAccessAndBilling
    end
    
    def create_supporter_list(site)
      supporter_list = @client.lists.build.defaults
      supporter_list["Title"] = "Supporters"
      supporter_list.Create
      site.update_attribute(:supporter_list_id, supporter_list.id)
    end
    
    def create_contributor_list(site)
      contributor_list = @client.lists.build.defaults
      contributor_list["Title"] = "Contributors"
      contributor_list.Create
      site.update_attribute(:contributor_list_id, contributor_list.id)
    end
end