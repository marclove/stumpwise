require 'test_helper'

class Admin::ArticlesControllerTest < ActionController::TestCase
  context "with administrator logged in" do
    setup { login_as(:admin) }
    
    context "on GET to :new" do
      setup do
        on_site(:with_content)
        get :new, :blog_id => items(:news_blog)
      end
      
      should_render_with :application, :new
      should_not_set_the_flash
      
      should "assign to @article with published set to true" do
        assert assigns(:article)
        assert_equal true, assigns(:article).published
      end
    end

    context "on POST to :create with valid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:save).returns(true).once
        Article.any_instance.stubs(:id).returns(1)
        post :create, :blog_id => items(:news_blog), :article => {}
      end
      
      should_redirect_to("parent blog's show page"){ admin_blog_path(items(:news_blog)) }
      should_assign_to :article
      should "set the site_id on the article to the current_site" do
        assert_equal sites(:with_content).id, assigns(:article).site_id
      end
      should_set_the_flash_to I18n.t("article.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:save).returns(false).once
        post :create, :blog_id => items(:news_blog), :article => {}
      end
      
      should_render_with :application, :new
      should_assign_to :article
      should_set_the_flash_to I18n.t("article.create.fail")
    end

    context "on GET to :edit" do
      setup do
        on_site(:with_content)
        get :edit, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end
      
      should_render_with :application, :edit
      should_assign_to :article
    end

    should "raise an error when attempting to :edit an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        get :edit, :blog_id => items(:news_blog), :id => 1
      end
    end
    
    context "on PUT to :update with valid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(true).once
        put :update, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id, :article => {}
      end
      
      should_redirect_to("parent blog's show page"){ admin_blog_path(items(:news_blog)) }
      should_set_the_flash_to I18n.t("article.update.success")
    end
    
    context "on PUT to :update with invalid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(false).once
        put :update, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id, :article => {}
      end
      
      should_render_with :application, :edit
      should_assign_to :article
      should_set_the_flash_to I18n.t("article.update.fail")
    end

    should "raise an error when attempting to :update an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :update, :blog_id => items(:news_blog), :id => 1
      end
    end
    
=begin
    context "on PUT to :publish" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(true).once
        put :publish, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end
      
      should_assign_to :article
    end
    
    should "raise an error when attempting to :publish an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :publish, :blog_id => items(:news_blog), :id => 1
      end
    end
    
    context "on PUT to :unpublish" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(true).once
        put :unpublish, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end
      
      should_assign_to :article
    end
    
    should "raise an error when attempting to :publish an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :unpublish, :blog_id => items(:news_blog), :id => 1
      end
    end
=end
    
    context "on DELETE to :destroy" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end
      
      should_redirect_to("parent blog's show page"){ admin_blog_path(items(:news_blog)) }
    end

    should "raise an error when attempting to :destroy an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        delete :destroy, :blog_id => items(:news_blog), :id => 1
      end
    end  
  end
  
  
  context "with authorized user but non-administrator logged in" do
    setup { login_as(:authorized) }

    context "on GET to :new" do
      setup do
        on_site(:with_content)
        get :new, :blog_id => items(:news_blog)
      end

      should_render_with :application, :new
      should_not_set_the_flash

      should "assign to @article with published set to true" do
        assert assigns(:article)
        assert_equal true, assigns(:article).published
      end
    end

    context "on POST to :create with valid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:save).returns(true).once
        Article.any_instance.stubs(:id).returns(1)
        post :create, :blog_id => items(:news_blog), :article => {}
      end

      should_redirect_to("parent blog's show page"){ admin_blog_path(items(:news_blog)) }
      should_assign_to :article
      should "set the site_id on the article to the current_site" do
        assert_equal sites(:with_content).id, assigns(:article).site_id
      end
      should_set_the_flash_to I18n.t("article.create.success")
    end

    context "on POST to :create with invalid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:save).returns(false).once
        post :create, :blog_id => items(:news_blog), :article => {}
      end

      should_render_with :application, :new
      should_assign_to :article
      should_set_the_flash_to I18n.t("article.create.fail")
    end

    context "on GET to :edit" do
      setup do
        on_site(:with_content)
        get :edit, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end

      should_render_with :application, :edit
      should_assign_to :article
    end

    should "raise an error when attempting to :edit an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        get :edit, :blog_id => items(:news_blog), :id => 1
      end
    end

    context "on PUT to :update with valid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(true).once
        put :update, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id, :article => {}
      end

      should_redirect_to("parent blog's show page"){ admin_blog_path(items(:news_blog)) }
      should_set_the_flash_to I18n.t("article.update.success")
    end

    context "on PUT to :update with invalid attributes" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(false).once
        put :update, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id, :article => {}
      end

      should_render_with :application, :edit
      should_assign_to :article
      should_set_the_flash_to I18n.t("article.update.fail")
    end

    should "raise an error when attempting to :update an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :update, :blog_id => items(:news_blog), :id => 1
      end
    end

=begin
    context "on PUT to :publish" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(true).once
        put :publish, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end

      should_assign_to :article
    end

    should "raise an error when attempting to :publish an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :publish, :blog_id => items(:news_blog), :id => 1
      end
    end

    context "on PUT to :unpublish" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:update_attributes).returns(true).once
        put :unpublish, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end

      should_assign_to :article
    end

    should "raise an error when attempting to :publish an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        put :unpublish, :blog_id => items(:news_blog), :id => 1
      end
    end
=end

    context "on DELETE to :destroy" do
      setup do
        on_site(:with_content)
        Article.any_instance.expects(:destroy).returns(true).once
        delete :destroy, :blog_id => items(:news_blog), :id => items(:news_blog_article_1).id
      end

      should_redirect_to("parent blog's show page"){ admin_blog_path(items(:news_blog)) }
    end

    should "raise an error when attempting to :destroy an article belonging to other site" do
      assert_raise ActiveRecord::RecordNotFound do
        on_site(:with_content)
        delete :destroy, :blog_id => items(:news_blog), :id => 1
      end
    end
  end
  
  
  context "with unauthorized user logged in" do
    setup do
      login_as(:unauthorized)
      on_site(:with_content)
    end

    context "on GET to :new" do
      setup { get :new, :blog_id => items(:news_blog) }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on POST to :create" do
      setup { post :create, :blog_id => items(:news_blog) }
      should_redirect_to("super admin login"){ admin_login_path }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => 1, :blog_id => items(:news_blog) }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on PUT to :update" do
      setup { put :update, :id => 1, :blog_id => items(:news_blog) }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on PUT to :publish" do
      setup { put :publish, :id => 1, :blog_id => items(:news_blog) }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on PUT to :unpublish" do
      setup { put :unpublish, :id => 1, :blog_id => items(:news_blog) }
      should_redirect_to("super admin login"){ admin_login_path }
    end
    
    context "on DELETE to :destroy" do
      setup { delete :destroy, :id => 1, :blog_id => items(:news_blog) }
      should_redirect_to("super admin login"){ admin_login_path }
    end
  end
end
