require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  context "Template:" do
    setup do
      @theme = Theme.create(:name => "theme")
    end

    context "An instance of a Template" do
      setup do
        @valid_attributes = {
          :filename => "template.tpl",
          :theme_id => @theme.id
        }
        def new_template(options={})
          Template.new(@valid_attributes.merge(options))
        end
      end

      should "save with valid attributes" do
        assert_difference 'Theme.first.templates.count' do
          @theme.templates << new_template
          @theme.save
          #assert template.errors.blank?
        end
      end

      should "have a _type of Template" do
        @theme.templates << template = new_template
        @theme.save
        assert 'Template', template._type
        assert 'Template'.constantize, template.class
      end
    end
  end
end
