require 'test_helper'

class Admin::BlogsControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup { login_as(:admin) }
    
    context "on GET to :index on inactive site" do
      setup do
        on_site(:inactive)
        get :index
      end
      
      should_respond_with :success
    end
    
    context "on GET to :index on site with no blogs" do
      setup do
        on_site(:without_content)
        get :index
      end
      
      should_render_with :application, :index
      should_not_set_the_flash
    end
    
    context "on GET to :index on site with blogs" do
      setup do
        on_site(:with_content)
        get :index
      end
      
      should_respond_with :redirect
    end
    
    context "on GET to :new" do
      setup do
        on_site(:with_content)
        get :new
      end
      
      should_render_with :application, :new
      should_not_set_the_flash
      
      should "assign to @blog with show_in_navigation and published set to true" do
        assert assigns(:blog)
        assert_equal true, assigns(:blog).show_in_navigation
        assert_equal true, assigns(:blog).published
      end
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:save).returns(true).once
        Blog.any_instance.stubs(:id).returns(1)
        post :create, :blog => {}
      end
      
      should_redirect_to("blog's show page"){ admin_blog_path(1) }
      should_assign_to :blog
      should_set_the_flash_to I18n.t("blog.create.success")
    end
    
    context "on POST to :create with invalid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:save).returns(false).once
        post :create, :blog => {}
      end
      
      should_render_with :application, :new
      should_assign_to :blog
      should_set_the_flash_to I18n.t("blog.create.fail")
    end
    
    context "on GET to :show" do
      setup do
        on_site(:with_content)
        get :show, :id => items(:news_blog).id
      end
      
      should_render_with :application, :show
      should_assign_to :blog, :blogs
      should_paginate :articles
    end
    
    should "raise an error when attempting to :show a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        get :show, :id => 1
      end
    end
    
    context "on GET to :edit" do
      setup do
        on_site(:with_content)
        get :edit, :id => items(:news_blog).id
      end
      
      should_render_with :application, :edit
      should_assign_to :blog
    end

    should "raise an error when attempting to :edit a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        get :edit, :id => 1
      end
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:update_attributes).returns(true).once
        put :update, :id => items(:news_blog).id, :blog => {}
      end
      
      should_redirect_to("blog's show page"){ admin_blog_path(items(:news_blog)) }
      should_set_the_flash_to I18n.t("blog.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:update_attributes).returns(false).once
        put :update, :id => items(:news_blog).id, :blog => {}
      end
      
      should_render_with :application, :edit
      should_assign_to :blog
      should_set_the_flash_to I18n.t("blog.update.fail")
    end

    should "raise an error when attempting to :update a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :update, :id => 1
      end
    end
    
    context "on DELETE to :destroy" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => items(:news_blog)
      end
      
      should_redirect_to("blogs listing"){ admin_blogs_path }
    end

    should "raise an error when attempting to :destroy a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        delete :destroy, :id => 1
      end
    end
  end
  
  
  context "with authorized user but non-administrator logged in" do
    setup { login_as(:authorized) }

    context "on GET to :index on site with no blogs" do
      setup do
        on_site(:without_content)
        get :index
      end
      
      should_render_with :application, :index
      should_not_set_the_flash
    end
    
    context "on GET to :index on site with blogs" do
      setup do
        on_site(:with_content)
        get :index
      end
      
      should_respond_with :redirect
    end
    
    context "on GET to :new" do
      setup do
        on_site(:with_content)
        get :new
      end
      
      should_render_with :application, :new
      should_not_set_the_flash
      
      should "assign to @blog with show_in_navigation and published set to true" do
        assert assigns(:blog)
        assert_equal true, assigns(:blog).show_in_navigation
        assert_equal true, assigns(:blog).published
      end
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:save).returns(true).once
        Blog.any_instance.stubs(:id).returns(1)
        post :create, :blog => {}
      end
      
      should_redirect_to("blog's show page"){ admin_blog_path(1) }
      should_assign_to :blog
      should_set_the_flash_to I18n.t("blog.create.success")
    end
    
    context "on POST to :create with invalid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:save).returns(false).once
        post :create, :blog => {}
      end
      
      should_render_with :application, :new
      should_assign_to :blog
      should_set_the_flash_to I18n.t("blog.create.fail")
    end
    
    context "on GET to :show" do
      setup do
        on_site(:with_content)
        get :show, :id => items(:news_blog).id
      end
      
      should_render_with :application, :show
      should_assign_to :blog, :blogs
      should_paginate :articles
    end
    
    should "raise an error when attempting to :show a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        get :show, :id => 1
      end
    end
    
    context "on GET to :edit" do
      setup do
        on_site(:with_content)
        get :edit, :id => items(:news_blog).id
      end
      
      should_render_with :application, :edit
      should_assign_to :blog
    end

    should "raise an error when attempting to :edit a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        get :edit, :id => 1
      end
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:update_attributes).returns(true).once
        put :update, :id => items(:news_blog).id, :blog => {}
      end
      
      should_redirect_to("blog's show page"){ admin_blog_path(items(:news_blog)) }
      should_set_the_flash_to I18n.t("blog.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:update_attributes).returns(false).once
        put :update, :id => items(:news_blog).id, :blog => {}
      end
      
      should_render_with :application, :edit
      should_assign_to :blog
      should_set_the_flash_to I18n.t("blog.update.fail")
    end

    should "raise an error when attempting to :update a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :update, :id => 1
      end
    end
    
    context "on DELETE to :destroy" do
      setup do
        on_site(:with_content)
        Blog.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => items(:news_blog)
      end
      
      should_redirect_to("blogs listing"){ admin_blogs_path }
    end

    should "raise an error when attempting to :destroy a blog belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        delete :destroy, :id => 1
      end
    end
  end
  
  
  context "with unauthorized user logged in" do
    setup do
      login_as(:unauthorized)
      on_site(:with_content)
    end

    context "on GET to :index" do
      setup { get :index }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on GET to :new" do
      setup { get :new }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on POST to :create" do
      setup { post :create }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
