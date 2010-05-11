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
