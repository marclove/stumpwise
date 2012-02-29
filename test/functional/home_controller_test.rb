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

class HomeControllerTest < ActionController::TestCase
  context "on POST to :create_site" do
    setup do
      setup_session_domain
      activate_authlogic
      @request.env['REMOTE_ADDR'] = "99.99.99.99"
    end
    
    context "and gateway successfully creates customer" do
      setup do
        Braintree::Customer.expects(:create).returns(gateway_customer_create_result(:success)).once
      end
      
      context "with valid user" do
        setup do
          User.any_instance.stubs(:valid?).returns(true)
        end
        
        context "and valid site" do
          setup do
            Site.any_instance.stubs(:valid?).returns(true)
          end
          
          context "and valid administratorship" do
            setup do
              Administratorship.any_instance.stubs(:valid?).returns(true)
              Theme.stubs(:first).returns(mock(:id => "randomid"))
              Site.any_instance.expects(:set_theme!).once.returns(true)
              post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
            end
            
            should_not_set_the_flash
            should_filter_params :number, :cvv
            should_assign_to :user, :class => User
            should_assign_to :site, :class => Site
            should "sign the new user in" do
              assert_equal assigns(:user).persistence_token, controller.session["user_credentials"]
            end
            should_change("the number of users", :by => 1) { User.count }
            should_change("the number of sites", :by => 1) { Site.count }
            should_change("the number of administratorships", :by => 1) { Administratorship.count }
            
            should_redirect_to("the admin of the newly created site"){ "http://tonywoods.stumpwise-local.com/admin/site/edit" }
            
            should "create the site with an initial status of active" do
              assert assigns(:site).active?
            end
            
            should "create the site with contribution processing turned off" do
              assert !assigns(:site).can_accept_contributions?
            end
            
            should "save the credit card token" do
              assert assigns(:site).credit_card_token.present?
            end
            
            should "save the credit card expiration date" do
              assert assigns(:site).credit_card_expiration.present?
            end            
          end
          
          context "and invalid administratorship" do
            setup do
              Administratorship.any_instance.expects(:valid?).returns(false).once
              post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
            end
            
            should_set_the_flash_to I18n.t("site.create.fail")
            should_filter_params :number, :cvv
            should_assign_to :user, :class => User
            should_assign_to :site, :class => Site
            should_render_with :marketing, :signup
            
            should "not change the number of users" do
              assert_no_difference "User.count" do
                post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
              end
            end
            
            should "not change the number of sites" do
              assert_no_difference "Site.count" do
                post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
              end
            end
            
            should "not change the number of administratorships" do
              assert_no_difference "Administratorship.count" do
                post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
              end
            end
          end
        end
        
        context "and invalid site" do
          setup do
            Site.any_instance.stubs(:valid?).returns(false)
            post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
          end
            
          should_set_the_flash_to I18n.t("site.create.fail")
          should_filter_params :number, :cvv
          should_assign_to :user, :class => User
          should_assign_to :site, :class => Site
          should_render_with :marketing, :signup
            
          should "not change the number of users" do
            assert_no_difference "User.count" do
              post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
            end
          end
          
          should "not change the number of sites" do
            assert_no_difference "Site.count" do
              post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
            end
          end
          
          should "not change the number of administratorships" do
            assert_no_difference "Administratorship.count" do
              post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
            end
          end
        end
      end
      
      context "with invalid user" do
        setup do
          User.any_instance.stubs(:valid?).returns(false)
          post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
        end
        
        should_set_the_flash_to I18n.t("site.create.fail")
        should_filter_params :number, :cvv
        should_assign_to :user, :class => User
        should_assign_to :site, :class => Site
        should_render_with :marketing, :signup
        
        should "not change the number of users" do
          assert_no_difference "User.count" do
            post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
          end
        end
        
        should "not change the number of sites" do
          assert_no_difference "Site.count" do
            post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
          end
        end
        
        should "not change the number of administratorships" do
          assert_no_difference "Administratorship.count" do
            post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
          end
        end
      end
      end
      
    context "and gateway rejects customer creation" do
      setup do
        Braintree::Customer.expects(:create).returns(gateway_customer_create_result(:error)).once
        post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
      end
        
      should_set_the_flash_to I18n.t("site.create.invalid_card")
      should_filter_params :number, :cvv
      should_assign_to :user, :class => User
      should_assign_to :site, :class => Site
      should_render_with :marketing, :signup
      
      should "not change the number of users" do
        assert_no_difference "User.count" do
          post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
        end
      end
      
      should "not change the number of sites" do
        assert_no_difference "Site.count" do
          post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
        end
      end
      
      should "not change the number of administratorships" do
        assert_no_difference "Administratorship.count" do
          post :create_site, :site => Factory.attributes_for(:site), :user => Factory.attributes_for(:user), :credit_card => credit_card(:cardholder_name => "John Doe")
        end
      end
    end
  end
end