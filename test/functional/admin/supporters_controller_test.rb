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
      should_assign_to :supporters
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
      should_assign_to :supporters
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
      should_assign_to :supporters
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
      should_assign_to :supporters
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
