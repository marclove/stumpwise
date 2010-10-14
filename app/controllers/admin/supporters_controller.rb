require 'csv'

class Admin::SupportersController < AdminController
  def index
    @supporterships = current_site.supporterships.find(:all, :include => [:supporter])
  end
  
  def show
    @supporter = current_site.supporters.find(params[:id])
    @supportership = Supportership.first(:conditions => {:supporter_id => @supporter, :site_id => current_site})
  end
  
  def export
    @supporterships = current_site.supporterships.find(:all, :order => 'created_at asc', :include => [:supporter])
    report = StringIO.new
    CSV::Writer.generate(report,',') do |r|
      r << ['Name Prefix','First Name','Last Name','Name Suffix','Email','Phone','Street Address','City','County','State','Zip Code','Country','Join Time']
      @supporterships.each do |s|
        r << [
          s.supporter.name_prefix,
          s.supporter.first_name,
          s.supporter.last_name,
          s.supporter.name_suffix,
          s.supporter.email,
          s.supporter.phone,
          s.supporter.thoroughfare,
          s.supporter.locality,
          s.supporter.subadministrative_area,
          s.supporter.administrative_area,
          s.supporter.postal_code,
          s.supporter.country,
          s.created_at.strftime('%Y-%m-%d %I:%M %p')]
      end
    end
    report.rewind
    respond_to do |format|
      format.csv { 
        send_data report.string, :type => "text/csv", :filename => "Supporters - #{Time.now.strftime('%Y-%m-%d-%H%M')}.csv"
      }
    end
  end
  
  def destroy
    @supporter = current_site.supporters.find(params[:id])
    @supporter.destroy
    redirect_to admin_supporters_path
  end
end
