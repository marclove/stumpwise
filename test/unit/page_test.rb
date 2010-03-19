require 'test_helper'

class PageTest < ActiveSupport::TestCase
  context "Page:" do
    setup do
      @theme = Theme.create(:name => "theme")
      @site = Site.create(:subdomain => "my_site", :theme => @theme)
    end
  
    context "An instance of a Page" do
      setup do
        @valid_attributes = {
          :title => "Test Page Title",
          :theme_id => @theme.id,
          :site_id => @site.id,
          :template_name => 'page.tpl'
        }
        def create_page(options={})
          Page.create(@valid_attributes.merge(options))
        end
      end
      
      should "save with valid attributes" do
        assert_difference 'Page.count' do
          page = create_page
          assert page.errors.blank?
        end
      end
      
      should "require a template name" do
        assert_no_difference 'Page.count' do
          page = create_page(:template_name => '')
          assert page.errors.on(:template_name)
        end
      end
    end
  end
end
