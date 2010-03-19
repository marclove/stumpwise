class SupportersController < ApplicationController
  def create
    @supporter = Supporter.new(params[:supporter])
    @supporter.site_id = current_site.id
    saved = @supporter.save
    if saved
      flash[:notice] = "Thank you for joining the campaign!"
      redirect_to '/'
    else
      redirect_to '/'
    end
  end
end
