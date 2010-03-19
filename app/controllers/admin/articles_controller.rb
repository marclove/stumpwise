class Admin::ArticlesController < ApplicationController
  def new
    @article = Article.new
  end
  
  def create
    @article = Article.new(params[:article])
    @article.site_id = current_site.id
    if @article.save
      flash[:notice] = t("article.create.success")
      redirect_to admin_blogs_path
    else
      flash[:error] = t("article.create.fail")
      render :action => 'new'
    end
  end

  def edit
    @article = current_site.articles.find(params[:id])
  end
  
  def update
    @article = current_site.articles.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = t("article.update.success")
      redirect_to admin_blogs_path
    else
      flash[:error] = t("article.update.fail")
      render :action => 'edit'
    end
  end
  
  def publish
    if @article = current_site.articles.find(params[:id])
      @article.update_attributes(:published => true)
    end
  end
  
  def unpublish
    if @article = current_site.articles.find(params[:id])
      @article.update_attributes(:published => false)
    end
  end
  
  def destroy
    @article = current_site.articles.find(params[:id])
    if @article.destroy
      flash[:notice] = t("article.destroy.success")
      redirect_to admin_blogs_path
    else
      flash[:error] = t("article.destroy.fail")
      render :action => 'edit'
    end
  end
end
