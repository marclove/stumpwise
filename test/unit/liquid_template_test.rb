require 'test_helper'

class LiquidTemplateTest < ActiveSupport::TestCase
  context "LiquidTemplate:" do
    setup do
      @theme = Theme.create(:name => "theme")
    end

    context "An instance of LiquidTemplate" do
      setup do
        @valid_attributes = {
          :filename => "liquid_template.tpl",
          :theme_id => @theme.id
        }
        def new_liquid_template(options={})
          LiquidTemplate.new(@valid_attributes.merge(options))
        end
      end
      
      should "require a filename" do
        assert_no_difference 'Theme.first.liquid_templates.count' do
          liquid_template = new_liquid_template(:filename => '')
          liquid_template.save
          #assert liquid_template.errors.on(:filename)
        end
      end
  
      should "require a theme_id" do
        assert_no_difference 'Theme.first.liquid_templates.count' do
          liquid_template = new_liquid_template(:theme_id => nil)
          liquid_template.save
          #assert liquid_template.errors.on(:theme_id)
        end
      end
  
      should "belong to a theme" do
        assert new_liquid_template.respond_to?(:theme_id)
        assert_equal @theme, new_liquid_template.theme
      end
  
      should_eventually "parse its content before saving" do
      end
  
      should_eventually "load its parsed content" do
      end
    end
  end
end
