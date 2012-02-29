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

class ContributionsController < ApplicationController
  layout nil
  before_filter :get_site
  filter_parameter_logging :number, :cvv
  
  def new
    @contribution = Contribution.new
    @credit_card = CreditCard.new
  end
  
  def create
    params[:contribution][:amount].delete!('$')
    @contribution = @site.contributions.build(params[:contribution])
    @contribution.ip = request.ip
    @credit_card = CreditCard.new(params[:credit_card])

    if @credit_card.valid? && @contribution.save
      @contribution.approve!(:approved, @credit_card.to_hash)
      if @contribution.approved?
        respond_to do |format|
          format.html { redirect_to "/#{@site.subdomain}/contribute/thanks/#{@contribution.order_id}" }
          format.js { render :nothing => true }
        end
      else
        @error = "#{t('contribution.process.fail.rejected')} #{@contribution.transaction_errors}"
        respond_to do |format|
          format.html do
            flash.now[:error] = @error
            render :action => 'new'
          end
          format.js { render :text => @error, :status => :unprocessable_entity }
        end
      end
    else
      @error = t('contribution.process.fail.invalid_record')
      respond_to do |format|
        format.html do
          flash.now[:error] = @error
          render :action => 'new'
        end
        format.js { render :text => @error, :status => :unprocessable_entity }
      end
    end
  end
  
  def thanks
    unless @contribution = @site.contributions.find_by_order_id(params[:order_id])
      raise ActiveRecord::RecordNotFound
    end
  end
  
  private
    def get_site
      unless @site = Site.contributable.find_by_subdomain(params[:site_subdomain])
        render :file => 'public/404.html', :status => 404
      end
    end
end
