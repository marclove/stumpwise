class Admin::ArticlesController < ApplicationController
  before_filter :require_authorized_user, :require_acceptance_of_campaign_agreement
  before_filter :get_blog

  def new
    @article = @blog.articles.build(:published => true)
  end
  
  def create
    @article = @blog.articles.build(params[:article])
    @article.site_id = current_site.id
    if @article.save
      flash[:notice] = t("article.create.success")
      redirect_to admin_blog_path(@blog)
    else
      flash[:error] = t("article.create.fail")
      render :action => 'new'
    end
  end

  def edit
    @article = @blog.articles.find(params[:id])
  end
  
  def update
    @article = @blog.articles.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = t("article.update.success")
      redirect_to admin_blog_path(@blog)
    else
      flash[:error] = t("article.update.fail")
      render :action => 'edit'
    end
  end
  
  def publish
    if @article = @blog.articles.find(params[:id])
      @article.update_attributes(:published => true)
    end
  end
  
  def unpublish
    if @article = @blog.articles.find(params[:id])
      @article.update_attributes(:published => false)
    end
  end
  
  def destroy
    @article = @blog.articles.find(params[:id])
    if @article.destroy
      flash[:notice] = t("article.destroy.success")
      redirect_to admin_blog_path(@blog)
    else
      flash[:error] = t("article.destroy.fail")
      render :action => 'edit'
    end
  end
  
  private
    def get_blog
      @blog = current_site.blogs.find(params[:blog_id])
    end
end
