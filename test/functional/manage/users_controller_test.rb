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

class Manage::UsersControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup { login_as(:admin) }
    
    context "with at least 11 users" do
      setup { 11.times{ User.make } }
      
      context "on GET to :index with no page given" do
        setup do
          get :index
        end
      
        should_respond_with :success
        should_render_with_layout :manage
        should_render_template :index
        should_not_set_the_flash
        should_assign_to :users
        should_assign_to(:page){ "1" }
    
        should "return the first 10 users" do
          assert_equal 10, assigns(:users).size
        end
      end
      
      context "on GET to :index requesting page 2" do
        setup do
          get :index, :page => "2"
        end
        
        should_respond_with :success
        should_render_with_layout :manage
        should_render_template :index
        should_not_set_the_flash
        should_assign_to :users
        should_assign_to(:page){ "2" }
      end  
    end
    
    should_eventually "on GET to :search"
    
    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :edit
      should_assign_to :user
      should_not_set_the_flash
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        User.any_instance.expects(:update_attributes).returns(true).once
        put :update, {:id => 1, :user => {:first_name => "New Name"}}
      end
      
      should_redirect_to("users listing"){ manage_users_path }
      should_set_the_flash_to I18n.t("user.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        User.any_instance.expects(:update_attributes).returns(false).once
        put :update, {:id => 1, :user => {:first_name => "New Name"}}
      end
      
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :edit
      should_assign_to :user
      should_set_the_flash_to I18n.t("user.update.fail")
    end
    
    context "on DELETE to :destroy with record that can be destroyed" do
      setup do
        User.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => 1
      end
      
      should_redirect_to("users listing"){ manage_users_path }
      should_set_the_flash_to I18n.t("user.destroy.success")
    end
    
    context "on DELETE to :destroy with record that can't be destroyed" do
      setup do
        @request.env["HTTP_REFERER"] = manage_users_path
        User.any_instance.expects(:destroy).returns(false).once
        delete :destroy, :id => 1
      end

      should_respond_with :redirect
      should_set_the_flash_to I18n.t("user.destroy.fail")
    end
  end
  
  context "with authorized user but non-administrator logged in" do
    setup { login_as(:authorized) }
    
    context "on GET to :index" do
      setup { get :index }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
  end

  context "with unauthorized user logged in" do
    setup { login_as(:unauthorized) }

    context "on GET to :index" do
      setup { get :index }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
  end
end
