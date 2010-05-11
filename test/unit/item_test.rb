require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  context "The Item class" do
    setup do
      @page = Page.make
    end
    
    should_validate_presence_of :title, :slug, :site_id
    should_validate_uniqueness_of :slug, :scoped_to => [:site_id, :parent_id], :case_sensitive => false
    should_validate_uniqueness_of :permalink, :scoped_to => :site_id, :case_sensitive => false
    should_not_allow_values_for :permalink, "contribute", "join", "contributions", "contributions/new", "supporters", "supporters/new", "admin"

    should "have a named scope of root items" do
      assert Item.roots.include? items(:root_1)
      assert Item.roots.include? items(:root_2)
      assert Item.roots.include? items(:root_3)
    end
  
    should "have a named scope of leaf items" do
      assert Item.leaves.include? items(:child_2)
      assert Item.leaves.include? items(:child_3)
      assert Item.leaves.include? items(:grandchild_1)
      assert Item.leaves.include? items(:root_2)
      assert Item.leaves.include? items(:root_3)
    end
    
    should "have a named scope of published items" do
      assert Item.published.include?(items(:news_blog)) # published
      assert !Item.published.include?(items(:unpublished_blog))
    end
  end
  
  context "An item" do
    should_belong_to :site, :parent
    should_have_many :children
    
    should "be able to be transformed into a liquid drop" do
      assert_instance_of ItemDrop, Item.new.to_liquid
    end
    
    should "create a slug on create if none given" do
      i = Page.make(:title => "Test Title", :slug => "")
      assert_equal "test-title", i.slug
    end
    
    should "create a slug on update if slug has been cleared" do
      i = Page.make(:title => "Test Title", :slug => "my-other-slug")
      assert_equal "my-other-slug", i.slug
      i.update_attributes(:slug => "")
      assert_equal "test-title", i.slug
    end
    
    should "set the permalink on create if none given" do
      i = Page.make(:title => "Test Title", :slug => "", :permalink => "")
      assert_equal "test-title", i.permalink
    end
    
    should "change its permalink when its slug changes" do
      i = Page.make(:slug => "test-title")
      assert_equal "test-title", i.permalink
      i.update_attributes(:slug => "totally-new-random-title")
      assert_equal "totally-new-random-title", i.permalink
    end
    
    should "set the permalink on update if permalink has been cleared" do
      i = Page.make(:title => "Test Title", :permalink => "my-other-slug")
      assert_equal "my-other-slug", i.permalink
      i.update_attributes(:permalink => "")
      assert_equal "test-title", i.permalink
    end
    
    context "that's a root" do
      should "know it's a root item" do
        assert items(:root_1).root?
      end
      
      should "know its the landing page" do
        assert items(:root_1).landing_page?
      end
    end
    
    context "that's a parent" do
      should "not be destroyable" do
        assert_no_difference "Item.count" do
          assert_raise(Stumpwise::ParentItemDestroyError) do
            items(:root_1).destroy
          end
        end
      end
    end
    
    context "that's a child" do
      setup do
        @new_child = Page.new(
          :site_id => 1,
          :title => "New child",
          :body => "My new child page",
          :published => true,
          :show_in_navigation => true
        )
      end
      
      should "know it's not a root item" do
        assert !items(:child_1).root?
      end
      
      should "set its permalink based on its ancestors" do
        items(:root_1).children << @new_child
        assert_equal "issues/new-child", @new_child.permalink
      end
      
      should "change its permalink when its parent's slug changes" do
        items(:root_1).children << @new_child
        assert_equal "issues/new-child", @new_child.permalink
        items(:root_1).reload
        items(:root_1).update_attributes(:slug => "new-slug")
        @new_child.reload
        assert_equal "new-slug/new-child", @new_child.permalink
      end
      
      should "change its permalink when its level is changed" do
        assert_equal "issues/veterans", items(:child_1).permalink
        items(:child_1).move_to_root
        assert_equal "veterans", items(:child_1).permalink
      end
      
      should "change its permalink when its given a different parent" do
        assert_equal "issues/climate-change", items(:child_2).permalink
        items(:child_2).move_to_child_of(items(:root_2))
        assert_equal "about/climate-change", items(:child_2).permalink
      end
      
      should "have a parent that knows it is its child" do
        assert items(:root_1).children.include?(items(:child_1))
      end
      
      should "be movable to the root" do
        assert !items(:child_1).root?
        items(:child_1).move_to_root
        assert items(:child_1).root?
      end
      
      context "and has children" do
        should "bring its children with it when moving it to the root" do
          assert_equal 2, items(:grandchild_1).level
          items(:child_1).move_to_root
          assert_equal 1, items(:grandchild_1).level
        end
      end
    end
    
    context "that's a grandchild" do
      should "change its permalink when its root's slug changes" do
        assert_equal "issues/veterans/iraq", items(:grandchild_1).permalink
        items(:root_1).update_attributes(:slug => "new-slug")
        items(:grandchild_1).reload
        assert_equal "new-slug/veterans/iraq", items(:grandchild_1).permalink
      end
    end
    
    context "that has siblings" do
      should "return the item to its left" do
        assert_equal items(:child_1), items(:child_2).left_sibling
      end
      
      should "return the item to its right" do
        assert_equal items(:child_3), items(:child_2).right_sibling
      end

      should "return the previous item" do
        assert_equal items(:child_1), items(:child_2).previous
      end
      
      should "return the next item" do
        assert_equal items(:child_3), items(:child_2).next
      end
      
      should "be movable to the right" do
        assert_equal items(:child_1), items(:child_2).left_sibling
        items(:child_2).move_right
        assert_equal items(:child_3), items(:child_2).left_sibling
      end
      
      should "be movable to the left" do
        assert_equal items(:child_3), items(:child_2).right_sibling
        items(:child_2).move_left
        assert_equal items(:child_1), items(:child_2).right_sibling
      end
    end
  end
end
