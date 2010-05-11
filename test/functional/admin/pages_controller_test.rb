require 'test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup do
      login_as(:admin)
      on_site(:with_content)
    end
    
    context "on GET to :index" do
      setup { get :index }
      should_render_with :application, :index
      should_not_set_the_flash
      should_assign_to :pages
    end
    
    context "on GET to :new" do
      setup { get :new }
      should_render_with :application, :new
      should_not_set_the_flash
      should "assign to @page with show_in_navigation and published set to true" do
        assert assigns(:page)
        assert_equal true, assigns(:page).show_in_navigation
        assert_equal true, assigns(:page).published
      end
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(true).once
        Page.any_instance.stubs(:id).returns(1)
        post :create, :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should "set the site_id on the page to the current_site" do
        assert_equal sites(:with_content).id, assigns(:page).site_id
      end
      should_set_the_flash_to I18n.t("page.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(false).once
        post :create, :page => {}
      end
      
      should_render_with :application, :new
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.create.fail")
    end
    
    context "on GET to :edit" do
      setup { get :edit, :id => items(:about_page) }
      should_render_with :application, :edit
      should_assign_to :page
    end
    
    should "raise an error when attempting to :edit a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :edit, :id => 1
      end
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(true).once
        put :update, :id => items(:about_page), :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.success")
    end

    context "on PUT to :update with invalid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(false).once
        put :update, :id => items(:about_page), :page => {}
      end
      
      should_render_with :application, :edit
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.fail")
    end

    should "raise an error when attempting to :update a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        put :update, :id => 1
      end
    end
    
    context "on DELETE to :destroy" do
      setup do
        Page.any_instance.expects(:destroy).returns(true)
        delete :destroy, :id => items(:about_page)
      end
      should_redirect_to("pages listing"){ admin_pages_path }
    end
    
    should_eventually "on DELETE to :destroy that fails"
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
      should_assign_to :pages
    end
    
    context "on GET to :new" do
      setup { get :new }
      should_render_with :application, :new
      should_not_set_the_flash
      should "assign to @page with show_in_navigation and published set to true" do
        assert assigns(:page)
        assert_equal true, assigns(:page).show_in_navigation
        assert_equal true, assigns(:page).published
      end
    end
    
    context "on POST to :create with valid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(true).once
        Page.any_instance.stubs(:id).returns(1)
        post :create, :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should "set the site_id on the page to the current_site" do
        assert_equal sites(:with_content).id, assigns(:page).site_id
      end
      should_set_the_flash_to I18n.t("page.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        Page.any_instance.expects(:save).returns(false).once
        post :create, :page => {}
      end
      
      should_render_with :application, :new
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.create.fail")
    end
    
    context "on GET to :edit" do
      setup { get :edit, :id => items(:about_page) }
      should_render_with :application, :edit
      should_assign_to :page
    end
    
    should "raise an error when attempting to :edit a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        get :edit, :id => 1
      end
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(true).once
        put :update, :id => items(:about_page), :page => {}
      end
      should_redirect_to("pages listing"){ admin_pages_path }
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.success")
    end

    context "on PUT to :update with invalid attributes" do
      setup do
        Page.any_instance.expects(:update_attributes).returns(false).once
        put :update, :id => items(:about_page), :page => {}
      end
      
      should_render_with :application, :edit
      should_assign_to :page
      should_set_the_flash_to I18n.t("page.update.fail")
    end

    should "raise an error when attempting to :update a page belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        put :update, :id => 1
      end
    end
    
    context "on DELETE to :destroy" do
      setup do
        Page.any_instance.expects(:destroy).returns(true)
        delete :destroy, :id => items(:about_page)
      end
      should_redirect_to("pages listing"){ admin_pages_path }
    end
    
    should_eventually "on DELETE to :destroy that fails"
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
      setup { post :create }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1 }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
