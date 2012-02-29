# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
