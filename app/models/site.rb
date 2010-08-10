# == Schema Information
# Schema version: 20100725234858
#
# Table name: sites
#
#  id                         :integer(4)      not null, primary key
#  created_at                 :datetime
#  updated_at                 :datetime
#  subdomain                  :string(255)
#  custom_domain              :string(255)
#  theme_id                   :integer(4)
#  name                       :string(255)
#  subhead                    :string(255)
#  keywords                   :text
#  description                :text
#  disclaimer                 :text
#  campaign_email             :string(255)
#  campaign_phone             :string(255)
#  twitter_username           :string(255)
#  facebook_page_id           :string(255)
#  flickr_username            :string(255)
#  youtube_username           :string(255)
#  google_analytics_id        :string(255)
#  paypal_email               :string(255)
#  owner_id                   :integer(4)
#  campaign_monitor_password  :string(255)
#  supporter_list_id          :string(255)
#  contributor_list_id        :string(255)
#  candidate_photo            :string(255)
#  eligibility_statement      :text
#  campaign_legal_name        :string(255)
#  campaign_street            :string(255)
#  campaign_city              :string(255)
#  campaign_state             :string(255)
#  campaign_zip               :string(255)
#  time_zone                  :string(255)     default("Pacific Time (US & Canada)")
#  active                     :boolean(1)
#  credit_card_token          :string(255)
#  credit_card_expiration     :datetime
#  subscription_id            :string(255)
#  subscription_billing_cycle :integer(4)
#  can_accept_contributions   :boolean(1)
#

class Site < ActiveRecord::Base
  attr_accessible :subdomain, :custom_domain, :theme_id, :name, :subhead,
                  :keywords, :description, :disclaimer, :campaign_email,
                  :campaign_phone, :twitter_username, :facebook_page_id,
                  :flickr_username, :youtube_username, :google_analytics_id,
                  :paypal_email, :eligibility_statement, :candidate_photo,
                  :campaign_legal_name, :campaign_street, :campaign_city,
                  :campaign_state, :campaign_zip, :time_zone, :credit_card_token,
                  :credit_card_expiration, :subscription_id, :subscription_billing_cycle,
                  :active, :max_contribution_amount, :mongo_theme_id,
                  :mongo_theme_version_id, :mongo_theme_customization_id
  
  RESERVED_SUBDOMAINS = %w( www support blog billing help api cdn asset assets chat mail calendar docs documents apps app calendars mobile mobi static admin administration administrator moderator official store buy pages page ssl contribute )
  
  named_scope :active, :conditions => {:active => true}
  named_scope :contributable, :conditions => {:active => true, :can_accept_contributions => true}
  
  belongs_to  :owner, :class_name => 'User'
  has_many    :administratorships
  has_many    :administrators, :through => :administratorships
  has_many    :supporterships
  has_many    :supporters, :through => :supporterships
  has_many    :contributions
  
  has_many    :items,     :order => 'lft ASC'
  has_many    :pages,     :order => 'lft ASC'
  has_many    :blogs,     :order => 'lft ASC'
  has_many    :articles,  :order => 'lft DESC'
  has_many    :assets,    :order => 'created_at DESC'
    
  mount_uploader :candidate_photo, CandidatePhotoUploader
  
  before_validation       :downcase_subdomain
  before_validation       :downcase_custom_domain
  validates_uniqueness_of :subdomain, :case_sensitive => false
  validates_length_of     :subdomain, :within => 3..63,
                          :message => "is required and must be between 3 and 63 characters in length."
  validates_format_of     :subdomain, :with => /\A([a-z0-9]([a-z0-9\-_]{0,61}[a-z0-9])?)+\Z/,
                          :message => "can only contain alphanumeric characters, underscores and dashes. It must also begin and end with either a letter or a number."
  validates_exclusion_of  :subdomain, :in => RESERVED_SUBDOMAINS
  validates_uniqueness_of :custom_domain, :allow_blank => true
  validates_format_of     :custom_domain, :if => Proc.new {|site| !site.custom_domain.blank? }, 
                          :with => /\A([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])+\.)[a-zA-Z]{2,6}\Z/, #/\A([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}\Z/,
                          :message => 'is invalid. Please use the following format: "example.com"'
  validates_length_of     :campaign_email, :within => 6..100,   :allow_blank => false
  validates_format_of     :campaign_email, :with => RegEmailOk, :allow_blank => false
  validates_presence_of   :name, :campaign_legal_name, :time_zone, :owner_id
  
  after_create :add_to_campaign_monitor
  before_destroy :destroy_theme_customizations
  
  def campaign_email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:campaign_email, new_email)
  end  
  
  def sms_recipient_numbers
    supporters.all(:select => 'supporters.mobile_phone', :conditions => ['supporterships.receive_sms = ?', true]).collect(&:mobile_phone)
  end
  
  def root_url
    "http://#{domain}"
  end
  
  # If custom_domain is blank, it has to be nil, else MySQL's unique index freaks
  def custom_domain=(new_custom_domain)
    if new_custom_domain.blank?
      write_attribute(:custom_domain, nil)
    else
      super
    end
  end
  
  def domain
    custom_domain.blank? ? "#{subdomain}.#{BASE_URL}" : custom_domain
  end
  
  def root_item
    items.roots.first(:conditions => {:published => true, :show_in_navigation => true})
  end
  alias_method :landing_page, :root_item
  
  def navigation
    items.roots.all(:order => 'lft ASC', :conditions => {:published => true, :show_in_navigation => true})
  end
  
  def contribute_url
    if can_accept_contributions?
      protocol = (Rails.env.production? ? "https" : "http")
      "#{protocol}://secure.#{HOST}/#{subdomain}/contribute"
    end
  end
  
  def to_liquid
    SiteDrop.new(self)
  end
  
  def self.generate_subdomain(name)
    name.to_s.downcase.parameterize('_').scan(/([a-zA-Z0-9]([a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9])?)/).flatten[0]
  end
  
  def supporter_list
    CampaignMonitor::List[supporter_list_id] if supporter_list_id
  end
  
  def contributor_list
    CampaignMonitor::List[contributor_list_id] if contributor_list_id
  end
  
  def authorized_user?(user)
    user.super_admin? || administratorships.first(:conditions => {:administrator_id => user})
  end
  
  def set_theme!(theme_id)
    if (theme_id != self.mongo_theme_id) && # theme is being changed
       (theme = Theme.find(theme_id)) && # theme requested actually exists
       (customization = ThemeCustomization.generate(self.id, theme_id)) # customization successfully created

      # store the old customization_id
      old_customization = self.mongo_theme_customization_id
      
      if save_new_theme(theme_id, theme.versions.last.id.to_s, customization.id.to_s)
        # only delete the old customization if we successfully switched to the new theme
        ThemeCustomization.destroy(old_customization) if old_customization.present?
      else
        # switching to the new theme failed, cleanup & delete the newly generated customization
        customization.destroy
      end
    end
  end
  
  def template
    return nil unless theme = ThemeVersion.find(mongo_theme_version_id)
    theme_assigns = theme.to_liquid
    if mongo_theme_customization_id.present? && tc = ThemeCustomization.find(mongo_theme_customization_id)
      theme_assigns.deep_merge!(tc.to_liquid)
    end
    [Liquid::Template.parse(theme.code), theme_assigns]
  end
  
  def theme_customization
    ThemeCustomization.first({:id => self.mongo_theme_customization_id})
  end
  
  protected
    def destroy_theme_customizations
      ThemeCustomization.find_each({:site_id => self.id}) { |c| c.destroy }
    end
    
    def save_new_theme(theme_id, version_id, customization_id)
      self.mongo_theme_id = theme_id
      self.mongo_theme_version_id = version_id
      self.mongo_theme_customization_id = customization_id
      save
    end
    
    def downcase_subdomain
      self.subdomain.downcase! if self.subdomain
    end
    
    def downcase_custom_domain
      self.custom_domain.downcase! if self.custom_domain
    end
    
    def add_to_campaign_monitor
      Delayed::Job.enqueue CreateCampaignMonitorClientJob.new(self)
    end
end
