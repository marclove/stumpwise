require 'test_helper'

class Admin::ContributionsControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup do
      login_as(:admin)
      on_site(:with_content)
    end
    
    context "on GET to :index" do
      setup { get :index }
      should_render_with :application, :index
      should_not_set_the_flash
      should_paginate :contributions
      should_assign_to(:contribution_total){ 85.00 }
    end
    
    should_eventually "on GET to :search"
    
    context "on GET to :show" do
      setup { get :show, :id => contributions(:with_content_approved_1) }
      should_render_with :application, :show
      should_not_set_the_flash
      should_assign_to :contribution
    end
    
    should "raise an error when attempting to :show a contribution belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :show, :id => 1
      end
    end
    
    context "on PUT to :refund that's successful" do
      setup do
        Contribution.any_instance.expects(:reverse).returns(true)
        put :refund, :id => contributions(:with_content_approved_1)
      end
      
      should_redirect_to("contribution show page"){ admin_contribution_path(contributions(:with_content_approved_1))}
      should_set_the_flash_to I18n.t('contribution.refund.success')
    end
    
    context "on PUT to :refund that fails" do
      setup do
        Contribution.any_instance.expects(:reverse).raises(Stumpwise::Transaction::ReversalError, "Could not be refunded")
        put :refund, :id => contributions(:with_content_approved_1)
      end
      
      should_redirect_to("contribution show page"){ admin_contribution_path(contributions(:with_content_approved_1))}
      should_set_the_flash_to "#{I18n.t('contribution.refund.rejected')} Could not be refunded"
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
      should_paginate :contributions
      should_assign_to(:contribution_total){ 85.00 }
    end
    
    should_eventually "on GET to :search"
    
    context "on GET to :show" do
      setup { get :show, :id => contributions(:with_content_approved_1) }
      should_render_with :application, :show
      should_not_set_the_flash
      should_assign_to :contribution
    end
    
    should "raise an error when attempting to :show a contribution belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :show, :id => 1
      end
    end
    
    context "on PUT to :refund that's successful" do
      setup do
        Contribution.any_instance.expects(:reverse).returns(true)
        put :refund, :id => contributions(:with_content_approved_1)
      end
      
      should_redirect_to("contribution show page"){ admin_contribution_path(contributions(:with_content_approved_1))}
      should_set_the_flash_to I18n.t('contribution.refund.success')
    end
    
    context "on PUT to :refund that fails" do
      setup do
        Contribution.any_instance.expects(:reverse).raises(Stumpwise::Transaction::ReversalError, "Could not be refunded")
        put :refund, :id => contributions(:with_content_approved_1)
      end
      
      should_redirect_to("contribution show page"){ admin_contribution_path(contributions(:with_content_approved_1))}
      should_set_the_flash_to "#{I18n.t('contribution.refund.rejected')} Could not be refunded"
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

    context "on PUT to :refund" do
      setup { put :refund, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
