require 'uuidtools'

class CreateCampaignMonitorClientJob < Struct.new(:site)
  def perform
    if create_client(site)
      create_supporter_list(site)
      create_contributor_list(site)
    end
  end

  def create_client(site)
    site.update_attribute(:campaign_monitor_password, UUIDTools::UUID.random_create.to_s[0..7])
    @client = CampaignMonitor::Client.new(
      "CompanyName"   => site.campaign_legal_name,
      "ContactName"   => site.owner.name,
      "EmailAddress"  => site.campaign_email,
      "Country"       => "United States of America",
      "Timezone"      => CM.timezones.select{|t| t =~ Regexp.new(Regexp.escape(site.time_zone))}.first
    )
    @client.Create
    @client["Username"] = site.subdomain
    @client["Password"] = site.campaign_monitor_password
    @client["AccessLevel"] = 47
    @client["BillingType"] = "ClientPaysWithMarkup"
    @client["Currency"] = "USD"
    @client["DeliveryFee"] = "25.0"
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