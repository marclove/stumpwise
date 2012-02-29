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

class ContributionsControllerTest < ActionController::TestCase
  context "on GET to :new" do
    setup do
      setup_session_domain
      get :new, :subdomain => "with-content"
    end
  
    should_assign_to :contribution, :class => Contribution
    should_assign_to(:site){ sites(:with_content) }
    should_respond_with :success
    should_render_without_layout
    should_render_template :new
    should_not_set_the_flash
  end
  
  context "on GET to :new for inactive site" do
    setup do
      setup_session_domain
      get :new, :subdomain => "inactive"
    end
    
    should_respond_with(404)
  end
  
  context "on GET to :new for site that can't accept contributions" do
    setup do
      setup_session_domain
      get :new, :subdomain => "cannot-accept-contributions"
    end
    
    should_respond_with(404)
  end

  context "on POST to :create" do
    setup { setup_session_domain }
  
    context "with everything valid and contribution approved" do
      setup do
        CreditCard.any_instance.expects(:valid?).returns(true)
        Contribution.any_instance.expects(:save).returns(true).once
        Contribution.any_instance.expects(:approve!).with(:approved, credit_card).returns(true).once
        Contribution.any_instance.expects(:approved?).returns(true)
        Contribution.any_instance.stubs(:order_id).returns("a84be")
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        post :create, {:subdomain => "with-content", :credit_card => credit_card, :contribution => {:amount => "$20.00"}}
      end
      should_assign_to :contribution, :class => Contribution
      should_assign_to :credit_card, :class => CreditCard
      should_assign_to(:site){ sites(:with_content) }
      should_redirect_to("the contribution receipt page"){ "/with-content/contribute/thanks/a84be" }
      should "set the contribution amount to 20.00" do
        assert_equal BigDecimal("20.00"), assigns(:contribution).amount
      end
      should "set the contribution ip address to 99.99.99.99" do
        assert_equal "99.99.99.99", assigns(:contribution).ip
      end
      should_filter_params :number, :cvv
    end
    
    context "with an invalid credit card" do
      setup do
        CreditCard.any_instance.expects(:valid?).returns(false)
        Contribution.any_instance.expects(:save).never
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        post :create, {:subdomain => "with-content", :credit_card => credit_card, :contribution => {:amount => "$20.00"}}
      end
      should_assign_to :contribution, :class => Contribution
      should_assign_to :credit_card, :class => CreditCard
      should_assign_to(:site){ sites(:with_content) }
      should_respond_with :success
      should_render_without_layout
      should_render_template :new
      should_set_the_flash_to I18n.t('contribution.process.fail.invalid_record')
      should_filter_params :number, :cvv
    end
  
    context "with an invalid contribution" do
      setup do
        CreditCard.any_instance.expects(:valid?).returns(true)
        Contribution.any_instance.expects(:save).returns(false).once
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        post :create, {:subdomain => "with-content", :credit_card => credit_card, :contribution => {:amount => "$20.00"}}
      end
      should_assign_to :contribution, :class => Contribution
      should_assign_to :credit_card, :class => CreditCard
      should_assign_to(:site){ sites(:with_content) }
      should_respond_with :success
      should_render_without_layout
      should_render_template :new
      should_set_the_flash_to I18n.t('contribution.process.fail.invalid_record')
      should_filter_params :number, :cvv
    end
  
    context "with everything valid and contribution rejected" do
      setup do
        CreditCard.any_instance.expects(:valid?).returns(true)
        Contribution.any_instance.expects(:save).returns(true).once
        Contribution.any_instance.expects(:approve!).with(:approved, credit_card).returns(true)
        Contribution.any_instance.expects(:approved?).returns(false)
        Contribution.any_instance.expects(:transaction_errors).returns("The processing error")
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        post :create, {
          :subdomain => "with-content", 
          :credit_card => credit_card, 
          :contribution => {:amount => "$20.00"}
        }
      end
      should_assign_to :contribution, :class => Contribution
      should_assign_to :credit_card, :class => CreditCard
      should_assign_to(:site){ sites(:with_content) }
      should_respond_with :success
      should_render_without_layout
      should_render_template :new
      should_set_the_flash_to "#{I18n.t('contribution.process.fail.rejected')} The processing error"
      should_filter_params :number, :cvv
    end
  end

  context "on GET to :thanks" do
    setup do
      setup_session_domain
      get :thanks, :subdomain => "with-content", :order_id => contributions(:with_content_approved_1).order_id
    end
  
    should_assign_to(:contribution){ contributions(:with_content_approved_1) }
    should_assign_to(:site){ sites(:with_content) }
    should_respond_with :success
    should_render_without_layout
    should_render_template :thanks
    should_not_set_the_flash
    should_eventually "verify the authenticity of the request (using session & authenticity token)"
  end

  should "on GET to :thanks requesting contribution belonging to other site" do
    assert_raise ActiveRecord::RecordNotFound do
      setup_session_domain
      get :thanks, :subdomain => "with-content", :order_id => contributions(:approved).order_id
    end
  end
end
