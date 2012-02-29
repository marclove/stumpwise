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
