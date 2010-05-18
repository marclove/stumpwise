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
    
    should "return its creator as a liquid drop" do
      assert @item_drop['creator'].is_a?(Liquid::Drop)
      assert_equal "Jeff Such", @item_drop['creator']['name']
    end
    
    should "return its updater as a liquid drop" do
      assert @item_drop['updater'].is_a?(Liquid::Drop)
      assert_equal "Jeff Such", @item_drop['updater']['name']
    end
    
    should "have a permalink attribute" do
      assert_equal "/about", @item_drop['permalink']
    end
    
    context "with sibling to its left" do
      should "return its left sibling as a drop" do
        assert_equal items(:root_1).to_liquid, @item_drop['previous']
      end
    end
    
    context "with a sibling to its right" do
      should "return its right sibling as a drop" do
        assert_equal items(:root_3).to_liquid, @item_drop['next']
      end
    end
    
    context "with a parent" do
      setup do
        @item_drop = items(:child_1).to_liquid
      end
      
      should "return its parent as a drop" do
        assert_equal items(:root_1).to_liquid, @item_drop['parent']
      end
    end
    
    context "with children" do
      setup do
        @item_drop = items(:root_1).to_liquid
      end
      
      should "return its children as an array of drops" do
        assert_contains items(:child_1).to_liquid, @item_drop['children'][0]
        assert_contains items(:child_2).to_liquid, @item_drop['children'][1]
        assert_contains items(:child_3).to_liquid, @item_drop['children'][2]
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