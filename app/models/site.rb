# == Schema Information
# Schema version: 20100916062732
#
# Table name: sites
#
#  id                            :integer(4)      not null, primary key
#  created_at                    :datetime
#  updated_at                    :datetime
#  subdomain                     :string(255)
#  custom_domain                 :string(255)
#  theme_id                      :integer(4)
#  name                          :string(255)
#  subhead                       :string(255)
#  keywords                      :text
#  description                   :text
#  disclaimer                    :text
#  campaign_email                :string(255)
#  campaign_phone                :string(255)
#  twitter_username              :string(255)
#  facebook_page_id              :string(255)
#  flickr_username               :string(255)
#  youtube_username              :string(255)
#  google_analytics_id           :string(255)
#  paypal_email                  :string(255)
#  owner_id                      :integer(4)
#  campaign_monitor_password     :string(255)
#  supporter_list_id             :string(255)
#  contributor_list_id           :string(255)
#  candidate_photo               :string(255)
#  eligibility_statement         :text
#  campaign_legal_name           :string(255)
#  campaign_street               :string(255)
#  campaign_city                 :string(255)
#  campaign_state                :string(255)
#  campaign_zip                  :string(255)
#  time_zone                     :string(255)     default("Pacific Time (US & Canada)")
#  active                        :boolean(1)
#  credit_card_token             :string(255)
#  credit_card_expiration        :datetime
#  subscription_id               :string(255)
#  subscription_billing_cycle    :integer(4)
#  can_accept_contributions      :boolean(1)
#  max_contribution_amount       :integer(4)      default(2400)
#  mongo_theme_id                :string(255)
#  mongo_theme_version_id        :string(255)
#  mongo_theme_customization_id  :string(255)
#  suggested_contribution_amount :integer(4)
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
                  :active, :max_contribution_amount, :suggested_contribution_amount,
                  :mongo_theme_id, :mongo_theme_version_id, :mongo_theme_customization_id
  
  RESERVED_SUBDOMAINS = %w( www support blog billing help api cdn asset assets chat mail email calendar docs documents apps app calendars mobile mobi static admin administration administrator moderator official store buy pages page ssl contribute secure )
  
  named_scope :active, :conditions => {:active => true}
  named_scope :contributable, :conditions => {:active => true, :can_accept_contributions => true}
  
  belongs_to  :owner, :class_name => 'User'
  has_many    :administratorships
  has_many    :administrators, :through => :administratorships
  has_many    :supporterships
  
  has_many    :supporters, :through => :supporterships do
    def add(attrs={})
      attrs = attrs.symbolize_keys
      receive_email = attrs.delete(:receive_email) || false
      receive_sms   = attrs.delete(:receive_sms)   || false
      
      if @supporter = Supporter.first(:conditions => {:email => attrs[:email]})
        @supporter.update_attributes!(attrs)
      else
        @supporter = Supporter.create(attrs)
      end
      
      if @supporter
        if supportership = Supportership.first(:conditions => {:site_id => proxy_owner.id, :supporter_id => @supporter.id})
          supportership.update_attributes(:receive_email => receive_email, :receive_sms => receive_sms)
        else
          Supportership.create(
            :site_id        => proxy_owner.id,
            :supporter_id   => @supporter.id,
            :receive_email  => receive_email,
            :receive_sms    => receive_sms
          )
        end
      end
    end
    
    def wanting_sms
      find(:all, :conditions => ["supporterships.receive_sms = ?", true])
    end
    
    def wanting_sms_count
      count(:conditions => ["supporterships.receive_sms = ?", true])
    end
  end
  
  has_one     :progress_tracker
  has_many    :contributions, :order => 'created_at DESC'
  has_many    :campaign_statements, :order => 'disbursed_on DESC'
  has_many    :sms_campaigns, :order => 'created_at DESC'
  
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
  validates_presence_of   :name, :subhead, :time_zone, :owner_id
  
  after_create :send_welcome_email, :add_to_campaign_monitor, :set_default_theme, :add_default_content
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
    custom_domain.blank? ? "#{subdomain}.#{HOST}" : custom_domain
  end
  
  def root_item
    items.roots.first(:conditions => {:published => true, :show_in_navigation => true})
  end
  alias_method :landing_page, :root_item
  
  def navigation
    items.roots.all(:order => 'lft ASC', :conditions => {:published => true, :show_in_navigation => true})
  end
  
  def contribute_url
    "https://secure.#{HOST}/#{subdomain}/contribute" if can_accept_contributions?
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

  def valid_payment_method_on_file?
    credit_card_token.present? && !credit_card_expired?
  end
  
  def credit_card_expired?
    Time.now.utc >= credit_card_expiration.utc
  end
  
  def generate_weekly_statement(disbursement_date)
    @contributions = self.contributions.disbursed_on(disbursement_date)
    statement = campaign_statements.create(
      :disbursed_on       => disbursement_date,
      :funds_available    => disbursement_date + 5,
      :starting           => (disbursement_date - 7).to_time.end_of_day,
      :ending             => (disbursement_date - 1).to_time,
      :total_raised       => self.contributions.paid.disbursed_on(disbursement_date).sum(:amount),
      :total_fees         => @contributions.sum(:processing_fees),
      :total_due          => @contributions.sum(:net_amount),
      :contributions      => @contributions
    )
    Delayed::Job.enqueue(WeeklyContributionsCampaignStatementJob.new(statement.id))
  rescue => e # don't want errors stopping the statement rake process
    HoptoadNotifier.notify(
      :error_class   => "Weekly Campaign Statement Generation Error",
      :error_message => "Error: #{e.message}",
      :parameters    => { 'site_id' => id, 'disbursement_date' => disbursement_date }
    )
  end
  
  def self.generate_weekly_summary_statement(disbursement_date)
    Delayed::Job.enqueue(WeeklyContributionsSummaryStatementJob.new(disbursement_date))
  rescue => e # don't want errors stopping the statement rake process
    HoptoadNotifier.notify(
      :error_class   => "Weekly Summary Statement Generation Error",
      :error_message => "Error: #{e.message}",
      :parameters    => { 'disbursement_date' => disbursement_date }
    )
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
    
    def send_welcome_email
      Delayed::Job.enqueue SendWelcomeEmailJob.new(self.id)
    end
    
    def add_default_content
      update_attributes(:twitter_username => 'stumpwise', :facebook_page_id => 'stumpwise')
      blog = self.blogs.create({:title => "Blog", :slug => 'blog', :published => true, :show_in_navigation => true})
      blog.articles.create({:title => "Welcome!", :slug => 'welcome', :published => true, :show_in_navigation => true, :body => "<p>My name is #{self.name} and I am running for #{self.subhead}. Thank you for visiting my campaign site.</p><p>The site is currently under construction. Please check back regularly for updates on the campaign and ways to get involved!</p>"})
      self.pages.create({:title => "About", :slug => 'about', :published => true, :show_in_navigation => true, :body => "Coming soon!"})
      self.pages.create({:title => "Issues", :slug => 'issues', :published => true, :show_in_navigation => true, :body => "Coming soon!"})
      self.pages.create({:title => "Contact", :slug => 'contact', :published => true, :show_in_navigation => true, :body => "Email: <a href=\"mailto:#{self.campaign_email}\">#{self.campaign_email}</a>"})
    end
    
    def set_default_theme
      self.set_theme!(Theme.first({:default => true}).id.to_s)
    end
end
