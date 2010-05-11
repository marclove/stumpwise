require 'test_helper'

class Admin::AssetsControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup do 
      login_as(:admin)
      on_site(:with_content)
    end
    
    context "on GET to :index" do
      setup { get :index }
      
      should_render_with :application, :index
      should_not_set_the_flash
      should_assign_to :assets
    end
    
    context "on GET to :new" do
      setup { get :new }
      
      should_render_with :application, :new
      should_not_set_the_flash
      should_assign_to :asset
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        Asset.any_instance.expects(:save).returns(true).once
        post :create, :asset => {}
      end
      
      should_redirect_to("assets listing"){ admin_assets_path }
      should_assign_to :asset
      should "set the site_id on the asset to current_site" do
        assert_equal sites(:with_content).id, assigns(:asset).site_id
      end
      should_set_the_flash_to I18n.t("asset.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        Asset.any_instance.expects(:save).returns(false).once
        post :create, :asset => {}
      end
      
      should_render_with :application, :new
      should_assign_to :asset
      should_set_the_flash_to I18n.t("asset.create.fail")
    end
    
    context "on DELETE to :destroy" do
      setup do
        Asset.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => assets(:for_site_with_content)
      end
      should_redirect_to("assets listing"){ admin_assets_path }
    end
    
    should "raise an error when attempting to :destroy an asset belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        delete :destroy, :id => assets(:for_other_site)
      end
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
      should_assign_to :assets
    end
    
    context "on GET to :new" do
      setup { get :new }
      
      should_render_with :application, :new
      should_not_set_the_flash
      should_assign_to :asset
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        Asset.any_instance.expects(:save).returns(true).once
        post :create, :asset => {}
      end
      
      should_redirect_to("assets listing"){ admin_assets_path }
      should_assign_to :asset
      should "set the site_id on the asset to current_site" do
        assert_equal sites(:with_content).id, assigns(:asset).site_id
      end
      should_set_the_flash_to I18n.t("asset.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        Asset.any_instance.expects(:save).returns(false).once
        post :create, :asset => {}
      end
      
      should_render_with :application, :new
      should_assign_to :asset
      should_set_the_flash_to I18n.t("asset.create.fail")
    end
    
    context "on DELETE to :destroy" do
      setup do
        Asset.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :id => assets(:for_site_with_content)
      end
      should_redirect_to("assets listing"){ admin_assets_path }
    end
    
    should "raise an error when attempting to :destroy an asset belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        delete :destroy, :id => assets(:for_other_site)
      end
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
    
    context "on GET to :new" do
      setup { get :new }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on POST to :create" do
      setup { post :create, :asset => {} }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
