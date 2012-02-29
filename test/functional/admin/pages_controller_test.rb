# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup do
      login_as(:admin)
      on_site(:with_content)
    end
    
    context "on GET to :index" do
      setup { get :index }
      should_render_with :application, :index
      should_not_set_the_flash
      should_assign_to :pages
    end
    
    context "on GET to :new" do
      setup { get :new }
      should_render_with :application, :new
      should_not_set_the_flash
      should "assign to @page with show_in_navigation and published set to true" do
        assert assigns(:page)
        assert_equal true, assigns(:page).show_in_navigation
        assert_equal true, assigns(:page).published
      end
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(true).once
        Page.any_instance.stubs(:id).returns(1)
        post :create, :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should "set the site_id on the page to the current_site" do
        assert_equal sites(:with_content).id, assigns(:page).site_id
      end
      should_set_the_flash_to I18n.t("page.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(false).once
        post :create, :page => {}
      end
      
      should_render_with :application, :new
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.create.fail")
    end
    
    context "on GET to :edit" do
      setup { get :edit, :id => items(:about_page) }
      should_render_with :application, :edit
      should_assign_to :page
    end
    
    should "raise an error when attempting to :edit a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :edit, :id => 1
      end
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(true).once
        put :update, :id => items(:about_page), :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.success")
    end

    context "on PUT to :update with invalid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(false).once
        put :update, :id => items(:about_page), :page => {}
      end
      
      should_render_with :application, :edit
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.fail")
    end

    should "raise an error when attempting to :update a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        put :update, :id => 1
      end
    end
    
    context "on DELETE to :destroy" do
      setup do
        Page.any_instance.expects(:destroy).returns(true)
        delete :destroy, :id => items(:about_page)
      end
      should_redirect_to("pages listing"){ admin_pages_path }
    end
    
    should_eventually "on DELETE to :destroy that fails"
  end


  context "with authorized user but non-administrator logged in" do
    setup do
      login_as(:authorized)
      on_site(:with_content)
    end
    
    context "on GET to :index" do
      setup { get :index }
      should_render_with :application, :index
      should_not_set_the_flash
      should_assign_to :pages
    end
    
    context "on GET to :new" do
      setup { get :new }
      should_render_with :application, :new
      should_not_set_the_flash
      should "assign to @page with show_in_navigation and published set to true" do
        assert assigns(:page)
        assert_equal true, assigns(:page).show_in_navigation
        assert_equal true, assigns(:page).published
      end
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(true).once
        Page.any_instance.stubs(:id).returns(1)
        post :create, :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should "set the site_id on the page to the current_site" do
        assert_equal sites(:with_content).id, assigns(:page).site_id
      end
      should_set_the_flash_to I18n.t("page.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(false).once
        post :create, :page => {}
      end
      
      should_render_with :application, :new
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.create.fail")
    end
    
    context "on GET to :edit" do
      setup { get :edit, :id => items(:about_page) }
      should_render_with :application, :edit
      should_assign_to :page
    end
    
    should "raise an error when attempting to :edit a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :edit, :id => 1
      end
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(true).once
        put :update, :id => items(:about_page), :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.success")
    end

    context "on PUT to :update with invalid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(false).once
        put :update, :id => items(:about_page), :page => {}
      end
      
      should_render_with :application, :edit
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.fail")
    end

    should "raise an error when attempting to :update a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        put :update, :id => 1
      end
    end
    
    context "on DELETE to :destroy" do
      setup do
        Page.any_instance.expects(:destroy).returns(true)
        delete :destroy, :id => items(:about_page)
      end
      should_redirect_to("pages listing"){ admin_pages_path }
    end
    
    should_eventually "on DELETE to :destroy that fails"
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
