require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  context "The Site class" do
    setup do
      @existing_site = Site.make
    end
    
    should_allow_mass_assignment_of :subdomain, :custom_domain, :theme_id,
      :name, :subhead, :keywords, :description, :disclaimer, :campaign_email,
      :campaign_phone, :twitter_username, :facebook_page_id,
      :flickr_username, :youtube_username, :google_analytics_id,
      :paypal_email, :eligibility_statement, :candidate_photo,
      :campaign_legal_name, :campaign_street, :campaign_city,
      :campaign_state, :campaign_zip, :time_zone
    
    should_validate_presence_of :name, :campaign_legal_name, :time_zone, :owner_id
    should_validate_uniqueness_of :subdomain, :case_sensitive => false
    should_ensure_length_in_range :subdomain, (3..63), {:short_message => "is required and must be between 3 and 63 characters in length.", :long_message => "is required and must be between 3 and 63 characters in length."}
    should_not_allow_values_for :subdomain, "-test", "test-", "test&1234", "test@1234", :message => "can only contain alphanumeric characters, underscores and dashes. It must also begin and end with either a letter or a number."
    should_allow_values_for :subdomain, "test-me", "test_me", "1test", "test1"
    should_not_allow_values_for :subdomain, "www", "support", "blog", "billing", "help", "api", "cdn", "asset", "assets", "chat", "mail", "calendar", "docs", "documents", "apps", "app", "calendars", "mobile", "mobi", "static", "admin", "administration", "administrator", "moderator", "official", "store", "buy", "pages", "page", "ssl", "contribute"
    
    should_not_allow_values_for :custom_domain, "-test.com", "test-.com", "test&1234.com", "test@1234.com", "test.faketld", "www.test.com", :message => 'is invalid. Please use the following format: "example.com"'
    should "validate uniqueness of custom domain" do
      Site.make(:custom_domain => "me.com")
      s = Site.make_unsaved(:custom_domain => "me.com")
      s.save
      assert_equal I18n.translate('activerecord.errors.messages.taken'), s.errors.on(:custom_domain)
    end
    
    should_ensure_length_in_range :campaign_email, 6..100
    should_allow_values_for :campaign_email, "a@b.ly", "test@john.co.uk"
    should_not_allow_values_for :campaign_email, "notanemail", "no email"

    should "always store email as lower case" do
      s = Site.make(:campaign_email => "F@FOOBAR.COM")
      s.campaign_email.should == 'f@foobar.com'
    end
    
    should "generate a subdomain from a given title" do
      assert_equal "anthony_woods_for_congress", Site.generate_subdomain("Anthony Woods For Congress")
      assert_equal "a"*63, Site.generate_subdomain("A"*100)
      assert_equal "a_b_c_d", Site.generate_subdomain("!a@b$c&d")
    end
    
    should "have an active named scope that does not return inactive sites" do
      assert !Site.active.include?(sites(:inactive))
    end
    
    should "have a contributable named scope that does not return inactive sites or sites marked as not eligible to accept contributions" do
      assert !Site.contributable.include?(sites(:inactive))
      assert !Site.contributable.include?(sites(:cannot_accept_contributions))
    end
  end
  
  context "A site" do
    should_belong_to :owner
    should_have_many :administratorships, :administrators, :supporterships,
                     :supporters, :contributions, :items, :pages, :blogs,
                     :articles, :assets, :sms_campaigns
    
    
    context "when adding a new supporter whose info doesn't exist in the database" do
      setup do 
        @new_supporter = {
          :first_name => "New",
          :last_name => "Supporter",
          :mobile_phone => "4081111111",
          :email => "new.supporter@stumpwise.com",
          :receive_email => true,
          :receive_sms => true
        }
      end
      
      should "create a new supporter record" do
        assert_difference 'sites(:with_supporters).supporters.count', 1 do
          sites(:with_supporters).supporters.add(@new_supporter)
        end
      end
      
      should "create a new supportership record" do
        assert_difference 'sites(:with_supporters).supporterships.count', 1 do
          sites(:with_supporters).supporters.add(@new_supporter)
          supportership = sites(:with_supporters).supporterships.last
          assert_equal true, supportership.receive_email
          assert_equal true, supportership.receive_sms
        end
      end
    end

    context "when adding a supporter who already supports another site but with updated data" do
      setup do
        @updated_supporter = {
          :email => supporters(:other_site_supporter).email,
          :last_name => "Does",
          :receive_email => true,
          :receive_sms => true
        }
      end
      
      should "not create a new supporter record" do
        assert_no_difference 'Supporter.count' do
          sites(:with_supporters).supporters.add(@updated_supporter)
        end
      end
      
      should "update the existing supporter record" do
        assert_equal "Doe", supporters(:other_site_supporter).last_name
        sites(:with_supporters).supporters.add(@updated_supporter)
        assert_equal "Does", supporters(:other_site_supporter).reload.last_name
      end
            
      should "create a new supportership record" do
        assert_difference 'Supportership.count', 1 do
          sites(:with_supporters).supporters.add(@updated_supporter)
        end
      end
    end
    
    context "when attempting to add a supporter that already supports this site but with updated data" do
      setup do
        @updated_supporter = {
          :email => supporters(:email_only).email,
          :last_name => "Does",
          :receive_email => true,
          :receive_sms => true
        }
      end
      
      should "not create a new supporter record" do
        assert_no_difference 'Supporter.count' do
          sites(:with_supporters).supporters.add(@updated_supporter)
        end
      end
      
      should "not create a new supportership record" do
        assert_no_difference 'Supportership.count' do
          sites(:with_supporters).supporters.add(@updated_supporter)
        end
      end
      
      should "update the existing supporter record" do
        assert_equal "Doe", supporters(:email_only).last_name
        sites(:with_supporters).supporters.add(@updated_supporter)
        assert_equal "Does", supporters(:email_only).reload.last_name
      end
      
      should "update the existing supportership record" do
        supportership = Supportership.first(:conditions => {:site_id => sites(:with_supporters).id, :supporter_id => supporters(:email_only).id})
        assert_equal false, supportership.receive_sms
        sites(:with_supporters).supporters.add(@updated_supporter)
        assert_equal true, supportership.reload.receive_sms
      end
    end
        
    should "be able to be transformed into a liquid drop" do
      assert_instance_of SiteDrop, Site.new.to_liquid
    end
    
    should "downcase its subdomain" do
      assert_equal "mysubdomain", Site.make(:subdomain => "MYSUBDOMAIN").subdomain
    end
    
    should "downcase its custom domain" do
      assert_equal "mycustomdomain.com", Site.make(:custom_domain => "MYCUSTOMDOMAIN.COM").custom_domain
    end
    
    should "set its custom domain to nil if set to be an empty string" do
      assert_nil Site.make(:custom_domain => "").custom_domain
    end
    
    should "default to inactive on initialization" do
      assert !Site.new.active?
    end
    
    should "default to not being unable to accept contributions" do
      assert !Site.new.can_accept_contributions?
    end
    
    should "return its root item" do
      assert_equal items(:root_1), sites(:woods).root_item
    end
    
    should "not return an item as root if it is unpublished" do
      items(:root_1).update_attribute(:published, false)
      assert_not_equal items(:root_1), sites(:woods).root_item
    end
    
    should "not return an item as root if it is not marked to be shown in navigation" do
      items(:root_1).update_attribute(:show_in_navigation, false)
      assert_not_equal items(:root_1), sites(:woods).root_item
    end
    
    should "return its navigation items" do
      assert_same_elements [items(:root_1), items(:root_2), items(:root_3)], sites(:woods).navigation
    end
    
    should "not return an item in navigation if it is unpublished" do
      items(:root_2).update_attribute(:published, false)
      assert !sites(:woods).navigation.include?(items(:root_2))
    end

    should "not return an item in navigation if it is not marked to be shown in navigation" do
      items(:root_2).update_attribute(:show_in_navigation, false)
      assert !sites(:woods).navigation.include?(items(:root_2))
    end
    
    should_eventually "return a list of mobile numbers of supporters wanting sms messages"

    should "know if its credit card is expired" do
      site = Site.make(:credit_card_expiration => Time.now.utc)
      assert site.credit_card_expired?
      site = Site.make(:credit_card_expiration => Time.now.utc + 1.minute)
      assert !site.credit_card_expired?
    end
    
    should "know if it has a valid payment method on file" do
      # Expired card
      site = Site.make(:credit_card_token => "abc123", :credit_card_expiration => Time.now.utc)
      assert !site.valid_payment_method_on_file?
      # No card on file
      site = Site.make(:credit_card_token => nil, :credit_card_expiration => nil)
      assert !site.valid_payment_method_on_file?
      # Valid card on file
      site = Site.make(:credit_card_token => "abc123", :credit_card_expiration => Time.now.utc + 1.minute)
      assert site.valid_payment_method_on_file?
    end
    
    should "return a list of supporters that want sms messages" do
      assert_same_elements [supporters(:sms_only), supporters(:email_and_sms)], sites(:with_supporters).supporters.wanting_sms
    end
    
    should "know the number of supporters that want sms messages" do
      assert_equal 2, sites(:with_supporters).supporters.wanting_sms_count
    end
    
    should "verify that a super admin is an authorized user" do
      site = Site.make
      super_admin = User.make(:admin)
      assert site.authorized_user?(super_admin)
    end
    
    should "verify a site administrator as an authorized user" do
      assert sites(:woods).authorized_user?(users(:authorized))
    end
    
    should "not verify a user that's not a site administrator as an authorized user" do
      assert !sites(:woods).authorized_user?(users(:unauthorized))
    end
    
    context "without a custom domain" do
      setup do
        @without = Site.make(:subdomain => "test", :custom_domain => nil)
      end
      
      should "know its domain is subdomain.stumpwise.com" do
        assert_equal "test.stumpwise-local.com", @without.domain
      end
      
      should "know its root url is http://subdomain.stumpwise.com" do
        assert_equal "http://test.stumpwise-local.com", @without.root_url
      end
    end

    context "with a custom domain" do
      setup do
        @with = Site.make(:subdomain => "test", :custom_domain => "woodsforcongress.com")
      end
      
      should "know its domain is the subdomain.stumpwise.com" do
        assert_equal "woodsforcongress.com", @with.domain
      end
      
      should "know its root url is http://woodsforcongress.com" do
        assert_equal "http://woodsforcongress.com", @with.root_url
      end
    end
  end
end
