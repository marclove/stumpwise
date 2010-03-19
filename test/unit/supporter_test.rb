require 'test_helper'

class SupporterTest < ActiveSupport::TestCase
  context "A Supporter" do
    setup do
      def create_supporter(options={})
        Supporter.create({
          :site_id => Mongo::ObjectID.new,
          :first_name => Sham.name,
          :last_name => Sham.name,
          :email => Sham.email
        }.merge!(options))
      end
    end
    
    should "create a supporter" do
      assert_difference 'Supporter.count' do
        s = create_supporter
        assert s.errors.blank?
      end
    end
    
    should "belong to a site" do
      assert Supporter.new.respond_to?(:site)
    end
    
    should "require a site id" do
      assert_no_difference 'Supporter.count' do
        s = create_supporter(:site_id => nil)
        assert s.errors.on(:site_id)
      end
    end
    
    should "require a first name" do
      assert_no_difference 'Supporter.count' do
        s = create_supporter(:first_name => "")
        assert s.errors.on(:first_name)
      end
    end
    
    should "require a last name" do
      assert_no_difference 'Supporter.count' do
        s = create_supporter(:last_name => "")
        assert s.errors.on(:last_name)
      end
    end
    
    should "require an email" do
      assert_no_difference 'Supporter.count' do
        s = create_supporter(:email => "")
        assert s.errors.on(:email)
      end
    end
    
    should "ensure the email address is valid" do
      assert_no_difference 'Supporter.count' do
        s = create_supporter(:email => "invalid_email@address")
        assert s.errors.on(:email)
      end
    end
    
    should "downcase an email address before saving it" do
      s = create_supporter(:email => "ALLCAPS@GMAIL.COM")
      assert_equal "allcaps@gmail.com", s.email
    end
    
    should "have a street address" do
      s = create_supporter(:thoroughfare => "123 Anywhere Street")
      assert_equal "123 Anywhere Street", s.thoroughfare
    end
    
    should "have a locality" do
      s = create_supporter(:locality => "San Francisco")
      assert_equal "San Francisco", s.locality
    end
    
    should "have a county/subadministrative area" do
      s = create_supporter(:subadministrative_area => "Santa Clara")
      assert_equal "Santa Clara", s.subadministrative_area
    end
    
    should "have a state/region/administrative area" do
      s = create_supporter(:administrative_area => "CA")
      assert_equal "CA", s.administrative_area
    end
    
    should "have a country" do
      s = create_supporter(:country => "United States")
      assert_equal "United States", s.country
    end
    
    should "have a postal code" do
      s = create_supporter(:postal_code => "95111")
      assert_equal "95111", s.postal_code
    end
    
    should "know the user's full name" do
      s = create_supporter(:first_name => "Marc", :last_name => "Love")
      assert_equal "Marc Love", s.name
    end
  end
end
