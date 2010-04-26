# == Schema Information
# Schema version: 20100416182257
#
# Table name: sites
#
#  id                        :integer         not null, primary key
#  created_at                :datetime
#  updated_at                :datetime
#  subdomain                 :string(255)
#  custom_domain             :string(255)
#  theme_id                  :integer
#  name                      :string(255)
#  subhead                   :string(255)
#  keywords                  :text
#  description               :text
#  disclaimer                :text
#  campaign_email            :string(255)
#  campaign_phone            :string(255)
#  twitter_username          :string(255)
#  facebook_page_id          :string(255)
#  flickr_username           :string(255)
#  youtube_username          :string(255)
#  google_analytics_id       :string(255)
#  paypal_email              :string(255)
#  owner_id                  :integer
#  campaign_monitor_password :string(255)
#  supporter_list_id         :string(255)
#  contributor_list_id       :string(255)
#  candidate_photo           :string(255)
#  eligibility_statement     :text
#  campaign_legal_name       :string(255)
#  campaign_street           :string(255)
#  campaign_city             :string(255)
#  campaign_state            :string(255)
#  campaign_zip              :string(255)
#  time_zone                 :string(255)     default("Pacific Time (US & Canada)")
#

class Site < ActiveRecord::Base
  attr_accessible :subdomain, :custom_domain, :theme_id, :name, :subhead,
                  :keywords, :description, :disclaimer, :campaign_email,
                  :campaign_phone, :twitter_username, :facebook_page_id,
                  :flickr_username, :youtube_username, :google_analytics_id,
                  :paypal_email, :eligibility_statement, :candidate_photo,
                  :campaign_legal_name, :campaign_street, :campaign_city,
                  :campaign_state, :campaign_zip, :time_zone
  
  RESERVED_SUBDOMAINS = %w( www support blog billing help api cdn asset assets chat mail calendar docs documents apps app calendars mobile mobi static admin administration administrator moderator official store buy pages page ssl contribute )
  
  belongs_to  :owner, :class_name => 'User'
  has_many    :administratorships
  has_many    :administrators, :through => :administratorships
  has_many    :supporterships
  has_many    :supporters, :through => :supporterships
  has_many    :contributions
  
  belongs_to  :theme
  has_many    :layouts,     :through => :theme
  has_many    :templates,   :through => :theme
  
  has_many    :items,     :order => 'created_at ASC'
  has_many    :pages,     :order => 'created_at ASC'
  has_many    :blogs,     :order => 'created_at ASC'
  has_many    :articles,  :order => 'created_at DESC'
  has_many    :assets,    :order => 'created_at DESC'
    
  mount_uploader :candidate_photo, CandidatePhotoUploader
  
  before_validation       :downcase_subdomain
  before_validation       :downcase_custom_domain
  validates_uniqueness_of :subdomain
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
  validates_presence_of   :name, :campaign_legal_name, :time_zone
  
  def sms_recipient_numbers
    supporters.all(:select => 'supporters.mobile_phone', :conditions => ['supporterships.receive_sms = ?', true]).collect(&:mobile_phone)
  end
  
  def gateway
    ActiveMerchant::Billing::Base.gateway('paypal').new(
      :login => 'billing_api1.progressbound.com',
      :password => 'S3Z8JT73P5UA8H2F',
      :signature => 'AFcWxV21C7fd0v3bYYYRCpSSRl31AtqRsGGkj3Mi7JF9RjKunsb07YR-'
    )
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
    items.roots.first(:order => 'lft ASC', :conditions => {:published => true, :show_in_navigation => true})
  end
  alias_method :landing_page, :root_item
  
  def navigation
    items.roots.all(:order => 'lft ASC', :conditions => {:published => true, :show_in_navigation => true})
  end
  
  def contribute_url
    protocol = Rails.env == :production ? "https" : "http"
    "#{protocol}://secure.#{HOST}/#{subdomain}/contribute"
  end
  
  def assets
    Asset.all(:conditions => {:site_id => self.id.to_s}, :order => 'created_at desc')
  end
  
  def call_render(object, default_layout = nil, assigns = {}, controller = nil, options = {})
    assigns.update('site' => to_liquid, object.liquid_name => object.to_liquid)
    options.reverse_merge!(:layout => true)
    handler = Stumpwise::Liquid::LiquidTemplate.new(self)
    if options[:layout]
      handler.render(object.template, default_layout, assigns, controller)
    else
      handler.parse_inner_template(object.template, assigns, controller)
    end
  end
  
  def to_liquid
    SiteDrop.new(self)
  end
  
  def self.generate_subdomain(name)
    name.to_s.parameterize('_').scan(/([a-zA-Z0-9]([a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9])?)+/).flatten[0]
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
  
  protected
    def downcase_subdomain
      self.subdomain.downcase! if self.subdomain
    end
    
    def downcase_custom_domain
      self.custom_domain.downcase! if self.custom_domain
    end
end
