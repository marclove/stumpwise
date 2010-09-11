class Manage::ContributionsController < ManageController
  def index
    @contributions = Contribution.paginate(
      :page     => params[:page] || 1,
      :per_page => params[:per_page] || 20,
      :order    => 'created_at DESC',
      :include => [:site]
    )
  end
  
  def show
    @contribution = Contribution.find(params[:id])
  end
  
  def refund
    @contribution = Contribution.find(params[:id])
    @contribution.reverse
    flash[:notice] = t('contribution.refund.success')
  rescue => exception
    flash[:error] = "#{t('contribution.refund.rejected')} #{exception}"
  ensure
    redirect_to manage_contribution_path(@contribution)
  end
end
