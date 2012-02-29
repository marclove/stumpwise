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

class Admin::SupportersControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup do
      login_as(:admin)
      on_site(:with_content)
    end
    
    context "on GET to :index" do
      setup { get :index }
      should_render_with :application, :index
      should_not_set_the_flash
      should_assign_to :supporterships
    end
    
    context "on GET to :show" do
      setup { get :show, :id => supporters(:with_content_supporter_1).id }
      should_render_with :application, :show
      should_not_set_the_flash
      should_assign_to :supporter, :supportership
    end
    
    should "raise an error when attempting to :show a supporter belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :show, :id => supporters(:other_site_supporter).id
      end
    end
    
    context "on GET to :export" do
      setup { get :export, :format => 'csv' }
      should_assign_to :supporterships
      should_respond_with_content_type :csv
    end
    
    context "on DELETE to :destroy" do
      setup do
        Supporter.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => supporters(:with_content_supporter_1).id
      end
      should_redirect_to("supporters listing"){ admin_supporters_path }
    end
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
      should_assign_to :supporterships
    end
    
    context "on GET to :show" do
      setup { get :show, :id => supporters(:with_content_supporter_1).id }
      should_render_with :application, :show
      should_not_set_the_flash
      should_assign_to :supporter, :supportership
    end
    
    should "raise an error when attempting to :show a supporter belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :show, :id => supporters(:other_site_supporter).id
      end
    end
    
    context "on GET to :export" do
      setup { get :export, :format => 'csv' }
      should_assign_to :supporterships
      should_respond_with_content_type :csv
    end
    
    context "on DELETE to :destroy" do
      setup do
        Supporter.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => supporters(:with_content_supporter_1).id
      end
      should_redirect_to("supporters listing"){ admin_supporters_path }
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
    
    context "on GET to :show" do
      setup { get :show, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on GET to :export" do
      setup { get :export }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
