require 'test_helper'

class LayoutTest < ActiveSupport::TestCase
  context "Layout:" do
    setup do
      @theme = Theme.create(:name => "theme")
    end

    context "An instance of a Layout" do
      setup do
        @valid_attributes = {
          :filename => "layout.tpl",
          :theme_id => @theme.id
        }
        def new_layout(options={})
          Layout.new(@valid_attributes.merge(options))
        end
      end

      should "save with valid attributes" do
        assert_difference 'Theme.first.layouts.count' do
          @theme.layouts << new_layout
          @theme.save
        end
      end

      should "have a _type of Layout" do
        @theme.layouts << layout = new_layout
        @theme.save
        assert 'Layout', layout._type
        assert 'Layout'.constantize, layout.class
      end
    end
  end
end
