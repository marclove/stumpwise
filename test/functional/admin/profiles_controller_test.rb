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

class Admin::ProfilesControllerTest < ActionController::TestCase
  context "while logged in" do
    setup do
      login_as(:authorized)
      on_site(:with_content)
    end
  
    context "on GET to :edit" do
      setup { get :edit }
      should_render_with :application, :edit
      should_not_set_the_flash
      should_assign_to(:user){ users(:authorized) }
    end
  
    context "on PUT to :update with valid attributes" do
      setup do
        User.any_instance.expects(:update_attributes).returns(true).once
        put :update, :user => {}
      end
      should_assign_to(:user){ users(:authorized) }
      should_redirect_to("profile edit page"){ edit_admin_profile_path }
      should_set_the_flash_to I18n.t("profile.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        User.any_instance.expects(:update_attributes).returns(false).once
        put :update, :user => {}
      end
      should_assign_to(:user){ users(:authorized) }
      should_render_with :application, :edit
      should_set_the_flash_to I18n.t("profile.update.fail")
    end
  end
end
