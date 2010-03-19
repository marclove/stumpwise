require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  context 'A Site' do
    setup do
      @theme = Theme.create(:name => "test")
    end

    context 'Class' do
      should "generate subdomain that starts and ends with an alphanumeric character" do
        assert_equal "john_doe", Site.generate_subdomain("John Doe")
        assert_equal "john_doe", Site.generate_subdomain(" _ John Doe _ ")
        assert_equal "john_doe", Site.generate_subdomain("-John Doe-")
        assert_equal "john_s_site_number_7", Site.generate_subdomain("John's Site Number 7")
      end

      should "create a site" do
        assert_difference 'Site.count' do
          s = create_site
          assert s.errors.blank?
        end
      end

      should "require a subdomain" do
        assert_no_difference 'Site.count' do
          s = create_site(:subdomain => nil)
          assert s.errors.on(:subdomain)
          s = create_site(:subdomain => "")
          assert s.errors.on(:subdomain)
        end
      end

      should "downcase the subdomain before validation" do
        assert_difference 'Site.count' do
          s = Site.new(:subdomain => "AnthonyWoods", :theme => @theme)
          assert_equal "AnthonyWoods", s.subdomain
          assert s.valid?
          assert_equal "anthonywoods", s.subdomain
          assert s.save
          assert s.errors.blank?
        end
      end

      should "require the subdomain to begin with a letter or number" do
        assert_no_difference 'Site.count' do
          s = create_site(:subdomain => "-bad_subdomain")
          assert s.errors.on(:subdomain)
        end
      end

      should "require the subdomain to end with a letter or number" do
        assert_no_difference 'Site.count' do
          s = create_site(:subdomain => "bad_subdomain-")
          assert s.errors.on(:subdomain)
        end
      end

      should "require the subdomain to be between 3 and 63 characters long" do
        assert_no_difference 'Site.count' do
          s = create_site(:subdomain => "aa")
          assert s.errors.on(:subdomain)
        end
        assert_no_difference 'Site.count' do
          s = create_site(:subdomain => "a"*64)
          assert s.errors.on(:subdomain)
        end
      end

      should "require the subdomain to be unique" do
        assert_difference 'Site.count', 1 do
          s1 = create_site(:subdomain => "test")
          s2 = create_site(:subdomain => "test")
          assert s2.errors.on(:subdomain)
        end
      end

      should "forbid any reserved subdomains" do
        assert_no_difference 'Site.count' do 
          reserved_subdomains = %w( www support blog billing help api cdn asset assets chat mail calendar docs documents apps app calendars mobile mobi static admin administration administrator moderator official store buy pages page ssl )
          reserved_subdomains.each do |subdomain|
            s = create_site(:subdomain => subdomain)
            assert s.errors.on(:subdomain)
          end
        end
      end

      should "downcase the custom domain before validation" do
        assert_difference 'Site.count' do
          s = Site.new(:subdomain => "woods", :custom_domain => "AnthonyWoods.com", :theme => @theme)
          assert_equal "AnthonyWoods.com", s.custom_domain
          assert s.valid?
          assert_equal "anthonywoods.com", s.custom_domain
          assert s.save
          assert s.errors.blank?
        end
      end

      should "require the custom domain to begin with a letter or number" do
        assert_no_difference 'Site.count' do
          s = create_site(:custom_domain => "-bad_subdomain.com")
          assert s.errors.on(:custom_domain)
        end
      end

      should "require the custom domain to end with a letter or number" do
        assert_no_difference 'Site.count' do
          s = create_site(:custom_domain => "bad_subdomain-.com")
          assert s.errors.on(:custom_domain)
        end
      end

      should "require the custom domain to be longer than 2 characters" do
        assert_no_difference 'Site.count' do
          s = create_site(:custom_domain => "a.com")
          assert s.errors.on(:custom_domain)
        end
      end

      should "require the custom domain to be unique" do
        assert_difference 'Site.count', 1 do
          s1 = create_site(:custom_domain => "test.com")
          s2 = create_site(:custom_domain => "test.com")
          assert s2.errors.on(:custom_domain)
        end
      end
    end

    context 'Instance' do
      setup do
        @site = Site.new(:subdomain => "woods")
      end

      should "return the subdomain url for root_url" do
        assert_equal "http://woods.#{BASE_URL}", @site.root_url
      end
      
      context 'with a custom domain' do
        setup do
          @site.custom_domain = "anthonywoods.com"
        end
        
        should "return the custom domain for root_url" do
          assert_equal "http://anthonywoods.com", @site.root_url
        end
      end
    end
  end
      
=begin
      should "have many pages" do
        assert sites(:feingold).respond_to?(:pages)
        assert sites(:feingold).pages << pages(:page_one)
        assert_equal [pages(:page_one)], sites(:feingold).pages
      end

      should "have many blogs" do
        assert sites(:feingold).respond_to?(:blogs)
        assert sites(:feingold).blogs << blogs(:news)
        assert_equal [blogs(:news)], sites(:feingold).blogs
      end

      should "belong to a theme" do
        assert sites(:feingold).respond_to?(:theme)
        assert sites(:feingold).theme = themes(:main)
        assert_equal themes(:main), sites(:feingold).theme
      end
=end

  protected
    def create_site(options={})
      Site.create({:subdomain => "anthony_woods-1", :theme => @theme}.merge(options))
    end
end
