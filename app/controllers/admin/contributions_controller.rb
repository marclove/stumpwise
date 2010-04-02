class Admin::ContributionsController < ApplicationController
  before_filter :require_authorized_user

  def index
    @contribution_total = current_site.contributions.processed.sum(:amount)
    @contributions = current_site.contributions.paginate(
      :page     => params[:page] || 1,
      :per_page => params[:per_page] || 20,
      :order    => 'created_at DESC'
    )
  end
  
  def search
    conditions = {}
    [:order_id, :email, :amount, :status, :first_name, :last_name, :city, :state, :zip].each do |k|
      conditions[k] = params[:k] unless params[k].blank?
    end
    @contributions = current_site.contributions.paginate(
      :page       => params[:page] || 1,
      :per_page   => params[:per_page] || 20,
      :order      => params[:order] || 'created_at DESC',
      :conditions => conditions
    )
  end
  
  def show
    @contribution = current_site.contributions.find(params[:id])
  end
  
  def refund
    @contribution = current_site.contributions.find(params[:id])
    response = @contribution.refund
    if response.success?
      flash[:notice] = t('contribution.refund.success')
    else
      flash[:error] = "#{t('contribution.refund.rejected')} #{response.message}"
    end
    redirect_to admin_contribution_path(@contribution)
  end
end
