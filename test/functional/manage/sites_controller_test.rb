require 'test_helper'

class Manage::SitesControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup { login_as(:admin) }
    
    context "on GET to :index" do
      setup { get :index }
      
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :index
      should_not_set_the_flash
      should_assign_to :sites
    
      should "return a list of all sites" do
        assert_equal Site.count, assigns(:sites).size
      end
    end
    
    context "on GET to :new" do
      setup { get :new }
      
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :new
      should_not_set_the_flash
      should_assign_to :site, :user
    end
    
    context "on POST to :create with a valid site and user" do
      setup do
        Theme.stubs(:first).returns(mock(:id => "randomid"))
        Site.any_instance.expects(:set_theme!).once.returns(true)
        post :create, {
          :site => Factory.attributes_for(:site),
          :user => Factory.attributes_for(:user)
        }
      end
      
      should_redirect_to("sites listing"){ manage_sites_path }
      should_not_set_the_flash
      should_create :site
      should_create :user
      should_assign_to :site, :user
      should_change("the number of administratorships", :by => 1){ Administratorship.count }
      should "make the user an administrator of the site" do
        a = Administratorship.last
        assert_equal assigns(:user).id, a.administrator_id
        assert_equal assigns(:site).id, a.site_id
      end
    end
    
    context "on POST to :create with an invalid site and valid user" do
      setup do
        post :create, { :site => {}, :user => Factory.attributes_for(:user)}
      end
      
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :new
      should_assign_to :site, :user
      should_set_the_flash_to I18n.t("site.create.fail")
    end

    context "on POST to :create with a valid site and invalid user" do
      setup do
        post :create, { :site => Factory.attributes_for(:site), :user => {}}
      end
      
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :new
      should_assign_to :site, :user
      should_set_the_flash_to I18n.t("site.create.fail")
    end
    
    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :edit
      should_assign_to :site
      should_not_set_the_flash
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        Site.any_instance.expects(:update_attributes).returns(true).once
        put :update, {:id => 1, :site => {:name => "New Name"}}
      end
      
      should_redirect_to("sites listing"){ manage_sites_path }
      should_set_the_flash_to I18n.t("site.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        Site.any_instance.expects(:update_attributes).returns(false).once
        put :update, {:id => 1, :site => {:name => "New Name"}}
      end
      
      should_respond_with :success
      should_render_with_layout :manage
      should_render_template :edit
      should_assign_to :site
      should_set_the_flash_to I18n.t("site.update.fail")
    end
    
    context "on DELETE to :destroy with record that can be destroyed" do
      setup do
        Site.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => 1
      end
      
      should_redirect_to("sites listing"){ manage_sites_path }
      should_set_the_flash_to I18n.t("site.destroy.success")
    end
    
    context "on DELETE to :destroy with record that can't be destroyed" do
      setup do
        @request.env["HTTP_REFERER"] = manage_sites_path
        Site.any_instance.expects(:destroy).returns(false).once
        delete :destroy, :id => 1
      end

      should_respond_with :redirect
      should_set_the_flash_to I18n.t("site.destroy.fail")
    end
  end
  
  context "with authorized user but non-administrator logged in" do
    setup { login_as(:authorized) }
    
    context "on GET to :index" do
      setup { get :index }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on GET to :new" do
      setup { get :new }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on POST to :create" do
      setup { post :create }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
  end

  context "with unauthorized user logged in" do
    setup { login_as(:unauthorized) }

    context "on GET to :index" do
      setup { get :index }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on GET to :new" do
      setup { get :new }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on POST to :create" do
      setup { post :create }
      should_redirect_to("super admin login"){ manage_login_path }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ manage_login_path }
    end
  end
end
