class Admin::BlogsController < ApplicationController
  before_filter :require_authorized_user, :require_acceptance_of_campaign_agreement

  def index
    @blogs = current_site.blogs
    if @blogs.size < 1
      @page = params[:page] || 1
      @articles = current_site.articles.paginate(
        :per_page => 5,
        :page => @page,
        :order => 'created_at desc'
      )
    else
      redirect_to admin_blog_path(@blogs.first)
    end
  end
  
  def new
    @blog = Blog.new(:show_in_navigation => true, :published => true)
  end
  
  def create
    @blog = Blog.new(params[:blog])
    @blog.site_id = current_site.id
    if @blog.save
      flash[:notice] = t('blog.create.success')
      redirect_to admin_blog_path(@blog)
    else
      flash[:error] = t('blog.create.fail')
      render :action => 'new'
    end
  end
  
  def show
    @blogs = current_site.blogs
    @blog = current_site.blogs.find(params[:id])
    @page = params[:page] || 1
    @articles = @blog.articles.paginate(
      :per_page => 5,
      :page => @page,
      :order => 'created_at desc'
    )
  end
  
  def edit
    @blog = current_site.blogs.find(params[:id])
  end
  
  def update
    @blog = current_site.blogs.find(params[:id])
    if @blog.update_attributes(params[:blog])
      flash[:notice] = t('blog.update.success')
      redirect_to admin_blog_path(@blog)
    else
      flash[:error] = t('blog.update.fail')
      render :action => 'edit'
    end
  end
  
  def destroy
    @blog = current_site.blogs.find(params[:id])
    @blog.destroy
    redirect_to admin_blogs_path
  end
end
