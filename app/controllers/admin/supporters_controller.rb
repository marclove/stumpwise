require 'csv'

class Admin::SupportersController < ApplicationController
  before_filter :require_authorized_user, :require_acceptance_of_campaign_agreement

  def index
    @supporters = current_site.supporters
  end
  
  def show
    @supporter = current_site.supporters.find(params[:id])
    @supportership = Supportership.first(:conditions => {:supporter_id => @supporter, :site_id => current_site})
  end
  
  def export
    @supporters = current_site.supporters.all(:order => 'created_at asc')
    report = StringIO.new
    CSV::Writer.generate(report,',') do |r|
      r << ['Name Prefix','First Name','Last Name','Name Suffix','Email','Phone','Street Address','City','County','State','Zip Code','Country','Join Time']
      @supporters.each do |s|
        r << [s.name_prefix,s.first_name,s.last_name,s.name_suffix,s.email,s.phone,s.thoroughfare,s.locality,s.subadministrative_area,s.administrative_area,s.postal_code,s.country,s.created_at]
      end
    end
    report.rewind
    respond_to do |format|
      format.csv { 
        send_data report.string, :type => "text/csv", :filename => "Supporters - #{Time.now.strftime('%Y-%m-%d-%H:%M')}.csv"
      }
    end
  end
  
  def destroy
    @supporter = current_site.supporters.find(params[:id])
    @supporter.destroy
    redirect_to admin_supporters_path
  end
end
