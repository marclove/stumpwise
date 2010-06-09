class Admin::ContributionsController < AdminController
  def index
    @contribution_total = current_site.contributions.approved.sum(:amount)
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
    @contribution.reverse
    flash[:notice] = t('contribution.refund.success')
  rescue => exception
    flash[:error] = "#{t('contribution.refund.rejected')} #{exception}"
  ensure
    redirect_to admin_contribution_path(@contribution)
  end
end
