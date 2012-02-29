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

class SupportersControllerTest < ActionController::TestCase
  context "Supporters Controller" do
    context "on POST to :create for inactive site" do
      setup do
        @request.env["HTTP_REFERER"] = "http://demo.stumpwise-local.com"
        setup_session_domain
        on_site(:inactive)
        post :create, :supporter => {:email => "newsupporter@stumpwise.com", :postal_code => '95123', :receive_email => true, :receive_sms => false}
      end
      
      should_respond_with(404)
    end
    
    context "on POST to :create" do
      setup do
        @request.env["HTTP_REFERER"] = "http://demo.stumpwise-local.com"
        setup_session_domain
        on_site(:with_content)
      end

      context "with a valid supporter attributes" do
        setup do
          post :create, :supporter => {:email => "newsupporter@stumpwise.com", :postal_code => '95123', :receive_email => true, :receive_sms => false}
        end
        
        should_respond_with :redirect
        should_create :supporter
        should_create :supportership
        
        should_change "the number of supporters for the current site", :by => 1 do
          sites(:with_content).supporters.count
        end
      end
      
      context "with invalid supporter attributes" do
        setup do
          post :create, :supporter => {}
        end
        
        should_respond_with :redirect
        should_not_change("the number of supporters") { Supporter.count }
        should_not_change("the number of supporterships") { Supportership.count }
      end
      
      context "with a supporter that already exists for another site" do
        setup do
          post :create, :supporter => { :email => supporters(:other_site_supporter).email, :receive_email => true, :receive_sms => false }
        end
        
        should_respond_with :redirect
        should_not_change("the number of supporters") { Supporter.count }
        should_create :supportership
        
        should_change "the number of supporters for the current site", :by => 1 do
          sites(:with_content).supporters.count
        end
      end
      
      context "with a supporter that already exists for the current site" do
        setup do
          post :create, :supporter => { :email => supporters(:with_content_supporter_1).email, :receive_email => true, :receive_sms => false }
        end
        
        should_respond_with :redirect
        should_not_change("the number of supporters") { Supporter.count }
        should_not_change("the number of supporterships") { Supportership.count }
      end
    end
  end
end
