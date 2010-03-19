require 'csv'

class Admin::SupportersController < ApplicationController
  def index
    @supporters = current_site.supporters
  end
  
  def show
    @supporter = current_site.supporters.find(params[:id])
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
        send_data report.string, :type => "application/csv", :filename => "Supporters - #{Time.now.strftime('%Y-%m-%d-%H:%M')}.csv"
      }
    end
  end
  
  def destroy
    @supporter = current_site.supporters.find(params[:id])
    @supporter.destroy
    redirect_to :back #admin_supporters
  end
end
