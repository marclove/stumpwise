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

class Admin::NavigationsControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup do
      login_as(:admin)
      on_site(:with_content)
    end
    
    context "on GET to :show" do
      setup { get :show }
      should_render_with :application, :show
      should_not_set_the_flash
      should_assign_to :items
    end
    
    should_eventually "test on PUT to :update"
  end


  context "with authorized user but non-administrator logged in" do
    setup do
      login_as(:authorized)
      on_site(:with_content)
    end
    
    context "on GET to :show" do
      setup { get :show }
      should_render_with :application, :show
      should_not_set_the_flash
      should_assign_to :items
    end
    
    should_eventually "test on PUT to :update"
  end


  context "with unauthorized user logged in" do
    setup do
      login_as(:unauthorized)
      on_site(:with_content)
    end
    
    context "on GET to :show" do
      setup { get :show }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
