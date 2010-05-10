require 'test_helper'

class LiquidTemplateTest < ActiveSupport::TestCase
  context "A LiquidTemplate" do
    setup do
      @existing = Layout.make
    end
    
    should_belong_to :theme
    should_validate_presence_of :theme_id, :type, :filename
    should_validate_uniqueness_of :filename, :scoped_to => [:theme_id]
    
    should "parse its content" do
      assert_instance_of Liquid::Template, @existing.parsed
    end
  end
end
