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

class Admin::SitesControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup do
      login_as(:admin)
      on_site(:with_content)
    end
    
    context "on GET to :edit" do
      setup { get :edit }
      should_render_with :application, :edit
      should_not_set_the_flash
      should_assign_to(:site){ sites(:with_content) }
    end
  
    context "on PUT to :update with valid attributes" do
      setup do
        Site.any_instance.expects(:update_attributes).returns(true).once
        put :update, :site => {}
      end
      should_assign_to(:site){ sites(:with_content) }
      should_redirect_to("site edit page"){ edit_admin_site_path }
      should_set_the_flash_to I18n.t("site.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        Site.any_instance.expects(:update_attributes).returns(false).once
        put :update, :site => {}
      end
      should_assign_to(:site){ sites(:with_content) }
      should_render_with :application, :edit
      should_set_the_flash_to I18n.t("site.update.fail")
    end
  end


  context "with authorized user but non-administrator logged in" do
    setup do
      login_as(:authorized)
      on_site(:with_content)
    end
    
    context "on GET to :edit" do
      setup { get :edit }
      should_render_with :application, :edit
      should_not_set_the_flash
      should_assign_to(:site){ sites(:with_content) }
    end
  
    context "on PUT to :update with valid attributes" do
      setup do
        Site.any_instance.expects(:update_attributes).returns(true).once
        put :update, :site => {}
      end
      should_assign_to(:site){ sites(:with_content) }
      should_redirect_to("site edit page"){ edit_admin_site_path }
      should_set_the_flash_to I18n.t("site.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        Site.any_instance.expects(:update_attributes).returns(false).once
        put :update, :site => {}
      end
      should_assign_to(:site){ sites(:with_content) }
      should_render_with :application, :edit
      should_set_the_flash_to I18n.t("site.update.fail")
    end
  end


  context "with unauthorized user logged in" do
    setup do
      login_as(:unauthorized)
      on_site(:with_content)
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
