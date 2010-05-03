class Admin::InfoController < ApplicationController
  def terms
  end
  
  def accept_terms
    current_user.update_attribute(:accepted_campaign_terms, true)
    redirect_back_or_default(admin_root_path)
  end
end