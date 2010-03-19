require 'test_helper'

class ThemeTest < ActiveSupport::TestCase
  context "Theme:" do
    context "An instance of Theme" do
      setup do
        @valid_attributes = { :name => "Test Theme" }
        def new_theme(options={})
          Theme.new(@valid_attributes.merge(options))
        end
      end
    
      should "require a name" do
        assert_no_difference 'Theme.count' do
          theme = new_theme(:name => '')
          theme.save
          assert theme.errors.on(:name)
        end
      end
    
      should "have many layouts" do
        assert new_theme.respond_to?(:layouts)
      end
    
      should "have many templates" do
        assert new_theme.respond_to?(:templates)
      end
    end
  end
end
