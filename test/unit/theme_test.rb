require 'test_helper'

class ThemeTest < ActiveSupport::TestCase
  should_have_many :sites, :liquid_templates, :layouts, :templates, :assets
  should_validate_presence_of :name
  
  context "Theme" do
    setup do
      @existing = Theme.new
    end
    
    should "parse its content" do
      assert_instance_of Liquid::Template, @existing.parsed
    end
  end
end
