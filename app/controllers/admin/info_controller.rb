class Admin::InfoController < AdminController
  skip_before_filter :require_acceptance_of_campaign_agreement
  
  def terms
  end
  
  def accept_terms
    current_user.update_attribute(:accepted_campaign_terms, true)
    redirect_back_or_default(admin_root_path)
  end
  
  def welcome
    
  end
end