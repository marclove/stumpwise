require 'test_helper'

class ItemDropTest < ActiveSupport::TestCase
  context "Item Drop" do
    setup do
      @item_drop = items(:root_2).to_liquid
    end
    
    should "have title attribute" do
      assert_equal "About", @item_drop['title']
    end
    
    should "have a slug attribute" do
      assert_equal "about", @item_drop['slug']
    end
    
    should "have show_in_navigation attribute" do
      assert_equal true, @item_drop['show_in_navigation']
    end
    
    should "have a created_at attribute" do
      assert @item_drop['created_at']
      assert @item_drop['created_at'].is_a?(Time)
    end

    should "have a updated_at attribute" do
      assert @item_drop['updated_at']
      assert @item_drop['updated_at'].is_a?(Time)
    end
    
    should "have a permalink attribute" do
      assert_equal "/about", @item_drop['permalink']
    end
    
    context "with sibling to its left" do
      should "return its left sibling as a drop" do
        assert @item_drop['previous'].is_a?(Liquid::Drop)
        assert_equal "Issues", @item_drop['previous']['title']
      end
    end
    
    context "with a sibling to its right" do
      should "return its right sibling as a drop" do
        assert @item_drop['next'].is_a?(Liquid::Drop)
        assert_equal "District", @item_drop['next']['title']
      end
    end
    
    context "with a parent" do
      setup do
        @item_drop = items(:child_1).to_liquid
      end
      
      should "return its parent as a drop" do
        assert @item_drop['parent'].is_a?(Liquid::Drop)
        assert_equal "Issues", @item_drop['parent']['title']
      end
    end
    
    context "with children" do
      setup do
        @item_drop = items(:root_1).to_liquid
      end
      
      should "return its children as an array of drops" do
        assert @item_drop['children'].is_a?(Array)
        @item_drop['children'].each do |c|
          assert c.is_a?(Liquid::Drop)
        end
        children_drop_names = @item_drop['children'].map{|c| c['title']}
        assert_contains children_drop_names, "Veterans"
        assert_contains children_drop_names, "Climate Change"
        assert_contains children_drop_names, "Healthcare"
      end
    end
    
    context "that's a root" do
      setup do
        @item_drop = items(:root_2).to_liquid
      end
      
      should "know that it's the root" do
        assert @item_drop['root?']
      end
      
      should "know that it's not a child" do
        assert !@item_drop['child?']
      end
    end
    
    context "that's a child" do
      setup do
        @item_drop = items(:child_1).to_liquid
      end
      
      should "know that it's not a root" do
        assert !@item_drop['root?']
      end
      
      should "know that it's a child" do
        assert @item_drop['child?']
      end
    end
    
    context "that's a leaf" do
      setup do
        @item_drop = items(:grandchild_1).to_liquid
      end
      
      should "know that it's a leaf" do
        assert @item_drop['leaf?']
      end
    end
    
    context "that's not a leaf" do
      setup do
        @item_drop = items(:root_1).to_liquid
      end
      
      should "know that it's not a leaf" do
        assert !@item_drop['leaf?']
      end
    end
    
    context "that's a site's landing page" do
      setup do
        @item_drop = items(:root_1).to_liquid
      end
      
      should "know that it's a landing page" do
        assert @item_drop['landing_page?']
      end
    end
    
    context "that's not a site's landing page" do
      setup do
        @item_drop = items(:root_2).to_liquid
      end
      
      should "know that it's not a landing page" do
        assert !@item_drop['landing_page?']
      end
    end
  end
end