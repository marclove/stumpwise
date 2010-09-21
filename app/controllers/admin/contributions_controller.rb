class Admin::ContributionsController < AdminController
  # TODO: Make the @contribution_total less hackish
  def index
    @todays_contributions = current_site.contributions.raised.sum(:amount, :conditions => ["contributions.created_at >= ?", Time.now.beginning_of_day.utc])
    @pending_disbursement = current_site.contributions.pending_disbursement.sum(:net_amount)
    @total_raised         = current_site.contributions.raised.sum(:amount)
    @contributions = current_site.contributions.paginate(
      :page     => params[:page] || 1,
      :per_page => params[:per_page] || 20,
      :order    => 'created_at DESC'
    )
  end
  
  def summary
    @todays_contributions = current_site.contributions.raised.sum(:amount, :conditions => ["contributions.created_at >= ?", Time.now.beginning_of_day.utc])
    @pending_distribution = current_site.contributions.settled.sum(:net_amount)
    @total_raised         = current_site.contributions.raised.sum(:amount)
    @recent_contributions = current_site.contributions.raised.find(:all, :limit => 10)
    #@contributions = Contribution.find_by_sql("SELECT CONCAT(YEAR(SUBTIME(contributions.created_at, '7:00:00')), '/', WEEK(SUBTIME(contributions.created_at, '7:00:00'))) AS cweek, sites.campaign_legal_name, SUM(contributions.amount), SUM(contributions.processing_fees), SUM(contributions.net_amount) FROM contributions INNER JOIN sites ON contributions.site_id = sites.id WHERE contributions.status = 'settled' AND contributions.test = 0 GROUP BY sites.campaign_legal_name, CONCAT(YEAR(contributions.created_at), '/', WEEK(contributions.created_at))")
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
  
  def settings
    @site = current_site
  end
  
  def update_settings
    @site = current_site
    if @site.update_attributes(params[:site])
      flash[:notice] = t("site.update.success")
      redirect_to settings_admin_contributions_path
    else
      flash.now[:error] = t("site.update.fail")
      render :action => 'settings'
    end
  end
  
  def export
    report = StringIO.new
    CSV::Writer.generate(report,',') do |r|
      r << ['Contribution ID','Email','First Name','Last Name','Address 1','Address 2','City','State','Zip Code','Phone','Employer','Occupation','Status','Amount','Fee','Net Amount','Contributed At']
      current_site.contributions.find(:all, :order => 'created_at asc').each do |c|
        r << [
          c.order_id,
          c.email,
          c.first_name,
          c.last_name,
          c.address1,
          c.address2,
          c.city,
          c.state,
          c.zip,
          c.phone,
          c.employer,
          c.occupation,          
          c.status,
          c.amount,
          c.processing_fees,
          c.net_amount,
          c.created_at.strftime('%Y-%m-%d %I:%M %p')]
      end
    end
    report.rewind
    respond_to do |format|
      format.csv { 
        send_data report.string, :type => "text/csv", :filename => "Contributions - #{Time.now.strftime('%Y-%m-%d-%H%M')}.csv"
      }
    end
  end
end
