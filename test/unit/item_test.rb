require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  context "Item:" do
    setup do
      @theme = Theme.create(:name => "theme")
      @site = Site.create(:subdomain => "my_site", :theme => @theme)
    end
  
    context "An instance of an Item" do
      setup do
        @valid_attributes = {
          :title => "Test Title",
          :theme_id => @theme.id,
          :site_id => @site.id
        }
        
        def new_item(options={})
          Item.new(@valid_attributes.merge(options))
        end
        
        def create_item(options={})
          Item.create(@valid_attributes.merge(options))
        end
      end
      
      should "save with valid attributes" do
        assert_difference 'Item.count' do
          item = create_item
          assert item.errors.blank?
        end
      end

      should "require a title on save" do
        assert_no_difference 'Item.count' do
          item = create_item(:title => nil)
          assert item.errors.on(:title)
        end
      end
    
      should "require a site" do
        assert_no_difference 'Item.count' do
          item = create_item(:site_id => nil)
          assert item.errors.on(:site_id)
        end
      end
      
      should "require that the slug be unique scoped to the site_id and parent_id" do
        other_site = Site.create(:subdomain => "my_site", :theme => @theme)
        parent    = create_item(:slug => "parent")
        item      = create_item(:slug => "slug", :parent => parent)
        dup_item  = create_item(:slug => "slug", :parent => parent)
        safe_dup1 = create_item(:slug => "slug")
        safe_dup2 = create_item(:slug => "slug", :site_id => other_site.id)
        
        assert dup_item.errors.on(:slug)
        # no error raised since it doesn't belong to the same parent
        assert !safe_dup1.errors.on(:slug)
        # no error raised since it doesn't belong to the same site
        assert !safe_dup2.errors.on(:slug)
      end

      should "create a slug on validate" do
        item = new_item
        item.valid?
        assert_equal "test-title", item.slug
      end
    
      should "set its path before saving" do
        item = new_item
        assert_equal [], item.path
        item.save
        assert_equal ['test-title'], item.path
      end
      
      should "correct its path when the slug changes" do
        parent = create_item(:slug => 'parent')
        child  = create_item(:slug => "child1", :parent => parent)
        assert_equal ['parent','child1'], child.path
        child.update_attributes(:slug => 'child2')
        assert_equal ['parent','child2'], child.path
      end
      
      should "correct its path when the parent's slug changes" do
        parent = create_item(:slug => 'parent1')
        child  = create_item(:slug => "child", :parent => parent)
        assert_equal ['parent1','child'], child.path
        parent.update_attributes(:slug => 'parent2')
        assert_equal ['parent2','child'], child.reload.path
      end
      
      should "set its position before saving" do
        item1 = create_item
        assert_equal 1, item1.position
        item2 = create_item(:title => "Other Title")
        assert_equal 2, item2.position
      end
      
      should "know if its the root item" do
        item1 = create_item
        item2 = create_item(:title => "Other Title")
        assert item1.root?
        assert !item2.root?
        item2.update_attributes(:parent_id => item1.id)
        assert !item2.root?
      end
      
      should "set its permalink before saving" do
        item = create_item(:slug => 'issues')
        assert_equal '/issues', item.permalink
      end
    
      should "belong_to a site" do
        assert Item.new.respond_to?(:site)
      end
    
      should "belong_to a parent" do
        assert Item.new.respond_to?(:parent)
      end
    
      should "have many children" do
        assert Item.new.respond_to?(:children)
      end
      
      context "that's a parent" do
        setup do
          @parent     = create_item(:title => 'Parent Item', :site => @site)
          @child      = create_item(:title => 'Child Item', :site => @site, :parent => @parent)
          @grandchild = create_item(:title => 'Grandchild Item', :site => @site, :parent => @child)
        end
        
        should "not be destroyable" do
          assert_no_difference 'Item.count' do
            @parent.destroy
          end
          assert_difference 'Item.count', -1 do
            @child.parent = nil
            @child.save
            @parent.destroy
          end
        end
        
        should "not be deleteable" do
          assert_no_difference 'Item.count' do
            @parent.delete
          end
          assert_difference 'Item.count', -1 do
            @child.parent = nil
            @child.save
            @parent.destroy
          end
        end
        
        should "prevent a cyclic re-parenting" do
          assert_raises Stumpwise::Exceptions::NavigationTreeError do
            @parent.update_attributes(:parent_id => @child.id)
            assert @parent.parent.nil?
          end

          assert_raises Stumpwise::Exceptions::NavigationTreeError do
            @parent.update_attributes(:parent_id => @child.id)
            assert @parent.parent.nil?
          end

          assert_raises Stumpwise::Exceptions::NavigationTreeError do
            @parent.update_attributes(:parent_id => @grandchild.id)
            assert @parent.parent.nil?
          end

          assert_raises Stumpwise::Exceptions::NavigationTreeError do
            @parent.update_attributes(:parent_id => @grandchild.id)
            assert @parent.parent.nil?
          end
        end
      end
      
      context "that's a child" do
        setup do
          @parent     = create_item(:title => 'Parent Item', :site => @site)
          @child      = create_item(:title => 'Child Item', :site => @site, :parent => @parent)
          @grandchild = create_item(:title => 'Grandchild Item', :site => @site, :parent => @child)
        end
        
        should "set its path properly on create" do
          assert_equal ['parent-item'], @parent.path
          assert_equal ['parent-item','child-item'], @child.path
          assert_equal ['parent-item','child-item','grandchild-item'], @grandchild.path
        end
        
        should "correct its path if necessary on save" do
          @grandchild.update_attributes(:parent_id => nil)
          assert_equal ['grandchild-item'], @grandchild.path
        end
      
        should "know the length of its path" do
          assert_equal 1, @parent.path_size
          assert_equal 2, @child.path_size
          assert_equal 3, @grandchild.path_size
        end
        
        should "correct the length of its path if necessary on save" do
          @grandchild.update_attributes(:parent_id => nil)
          assert_equal 1, @grandchild.path_size
        end
      
        should "know its parent" do
          assert @parent.parent.nil?
          assert_equal @parent, @child.parent
          assert_equal @child, @grandchild.parent
        end
        
        should "have its parent's id in its ancestor_ids" do
          assert_equal [], @parent.ancestor_ids
          assert_equal [@parent.id], @child.ancestor_ids
          assert_equal [@parent.id, @child.id], @grandchild.ancestor_ids
        end
      
        should "have a parent that knows it is its child" do
          assert @parent.children.include?(@child)
          assert @child.children.include?(@grandchild)
        end
        
        should "know its descendants" do
          assert @parent.descendants.include?(@child)
          assert @parent.descendants.include?(@grandchild)
        end
        
        should "set its permalink before saving" do
          assert_equal '/parent-item', @parent.permalink
          assert_equal '/parent-item/child-item', @child.permalink
          assert_equal '/parent-item/child-item/grandchild-item', @grandchild.permalink
        end
      end
    end
  end
end
