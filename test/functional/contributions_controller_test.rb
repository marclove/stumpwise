require 'test_helper'

class ContributionsControllerTest < ActionController::TestCase  
  context "on GET to :new" do
    setup do
      setup_session_domain
      get :new, :subdomain => "with-content"
    end
    
    should_assign_to :contribution, :class => Contribution
    should_assign_to :credit_card, :class => ActiveMerchant::Billing::CreditCard
    should_assign_to(:site){ sites(:with_content) }
    should_respond_with :success
    should_render_without_layout
    should_render_template :new
    should_not_set_the_flash
  end
  
  context "on POST to :create" do
    setup { setup_session_domain }
    
    context "with everything valid and contribution approved" do
      setup do
        response = mock()
        response.expects(:success?).returns(true).once
        Contribution.any_instance.expects(:valid?).returns(true).at_least_once
        Contribution.any_instance.expects(:save).returns(true).once
        Contribution.any_instance.expects(:process).with(instance_of(ActiveMerchant::Billing::CreditCard)).returns(response)
        Contribution.any_instance.stubs(:first_name).returns("John")
        Contribution.any_instance.stubs(:last_name).returns("Doe")
        Contribution.any_instance.stubs(:order_id).returns("a84be")
        ActiveMerchant::Billing::CreditCard.any_instance.expects(:valid?).returns(true).at_least_once
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        @opts = {:subdomain => "with-content", :credit_card => {}, :contribution => {}}
      end
      
      context "and amount from given choices" do
        setup do
          post :create, @opts.merge!(:amount_choice => "20.0")
        end
        should_assign_to :credit_card, :contribution
        should_assign_to(:site){ sites(:with_content) }
        should_redirect_to("the contribution receipt page"){ "/with-content/contribute/thanks/a84be" }
        should "set the contribution amount to 2000" do
          assert_equal 2000, assigns(:contribution).amount
        end
        should "set the contribution ip address to 99.99.99.99" do
          assert_equal "99.99.99.99", assigns(:contribution).ip
        end
        should "set credit_card name" do
          assert_equal "John", assigns(:credit_card).first_name
          assert_equal "Doe", assigns(:credit_card).last_name
        end
        should_filter_params :number, :verification_value
      end
      
      context "and other amount given" do
        setup do
          post :create, @opts.merge!(:amount_choice => "other", :amount_other => "12.34")
        end
        should_assign_to :credit_card, :contribution
        should_assign_to(:site){ sites(:with_content) }
        should_redirect_to("the contribution receipt page"){ "/with-content/contribute/thanks/a84be" }
        should "set the contribution amount to 1234" do
          assert_equal 1234, assigns(:contribution).amount
        end
        should "set the contribution ip address to 99.99.99.99" do
          assert_equal "99.99.99.99", assigns(:contribution).ip
        end
        should "set credit_card name" do
          assert_equal "John", assigns(:credit_card).first_name
          assert_equal "Doe", assigns(:credit_card).last_name
        end
        should_filter_params :number, :verification_value
      end
    end
    
    context "with an invalid contribution" do
      setup do
        Contribution.any_instance.expects(:valid?).returns(false).at_least_once
        Contribution.any_instance.expects(:save).returns(false).once
        Contribution.any_instance.stubs(:first_name).returns("John")
        Contribution.any_instance.stubs(:last_name).returns("Doe")
        ActiveMerchant::Billing::CreditCard.any_instance.expects(:valid?).returns(true).at_least_once
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        post :create, {:subdomain => "with-content", :credit_card => {}, :contribution => {}}
      end
      should_assign_to :credit_card, :contribution
      should_assign_to(:site){ sites(:with_content) }
      should_respond_with :success
      should_render_without_layout
      should_render_template :new
      should_set_the_flash_to I18n.t('contribution.process.fail.invalid_record')
      should_filter_params :number, :verification_value
    end
    
    context "with an invalid credit card" do
      setup do
        Contribution.any_instance.expects(:valid?).returns(true).at_least_once
        Contribution.any_instance.stubs(:first_name).returns("John")
        Contribution.any_instance.stubs(:last_name).returns("Doe")
        ActiveMerchant::Billing::CreditCard.any_instance.expects(:valid?).returns(false).at_least_once
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        post :create, {:subdomain => "with-content", :credit_card => {}, :contribution => {}}
      end
      should_assign_to :credit_card, :contribution
      should_assign_to(:site){ sites(:with_content) }
      should_respond_with :success
      should_render_without_layout
      should_render_template :new
      should_set_the_flash_to I18n.t('contribution.process.fail.invalid_card')
      should_filter_params :number, :verification_value
    end
    
    context "with everything valid and contribution rejected" do
      setup do
        response = mock()
        response.expects(:success?).returns(false).once
        response.expects(:message).returns("The processing error").once
        Contribution.any_instance.expects(:valid?).returns(true).at_least_once
        Contribution.any_instance.expects(:save).returns(true).once
        Contribution.any_instance.expects(:process).with(instance_of(ActiveMerchant::Billing::CreditCard)).returns(response)
        Contribution.any_instance.stubs(:first_name).returns("John")
        Contribution.any_instance.stubs(:last_name).returns("Doe")
        ActiveMerchant::Billing::CreditCard.any_instance.expects(:valid?).returns(true).at_least_once
        @request.env['REMOTE_ADDR'] = "99.99.99.99"
        post :create, {:subdomain => "with-content", :credit_card => {}, :contribution => {}}
      end
      should_assign_to :credit_card, :contribution
      should_assign_to(:site){ sites(:with_content) }
      should_respond_with :success
      should_render_without_layout
      should_render_template :new
      should_set_the_flash_to "#{I18n.t('contribution.process.fail.rejected')} The processing error"
      should_filter_params :number, :verification_value
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
