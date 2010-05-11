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
