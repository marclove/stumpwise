class ProgressObserver < ActiveRecord::Observer
  observe :site, :item
  
  def after_create(record)
    record.create_progress_tracker if record.is_a?(Site)
  end
  
  def after_save(record)
    if record.is_a?(Item) && record.site.progress_tracker
      check_content_created(record)
    end
  end
  
  def before_update(record)
    if record.is_a?(Site) && record.progress_tracker
      check_theme_customized(record)
      check_contact_info_entered(record)
      check_candidate_photo_uploaded(record)
      check_social_networks_added(record)
      check_custom_domain_setup(record)
      check_fundraising_activated(record)
    end
  end
  
  private
    def check_theme_customized(site)
      if site.mongo_theme_customization_id_changed?
        site.progress_tracker.update_attribute(:theme_customized, true)
      end
    end
    
    def check_contact_info_entered(site)
      if site.campaign_legal_name.present? &&
         site.campaign_street.present? &&
         site.campaign_city.present? &&
         site.campaign_state.present? &&
         site.campaign_zip.present?
        site.progress_tracker.update_attribute(:contact_info_entered, true)
      end
    end
    
    def check_candidate_photo_uploaded(site)
      if site.candidate_photo_changed? && site.candidate_photo.present?
        site.progress_tracker.update_attribute(:candidate_photo_uploaded, true)
      end
    end
    
    def check_social_networks_added(site)
      if ((site.twitter_username_changed? || site.facebook_page_id_changed?) &&
          (site.twitter_username.present? || site.facebook_page_id.present?))
        site.progress_tracker.update_attribute(:social_networks_added, true)
      end
    end
    
    def check_custom_domain_setup(site)
      if site.custom_domain_changed? && site.custom_domain.present?
        site.progress_tracker.update_attribute(:custom_domain_setup, true)
      end
    end
    
    def check_fundraising_activated(site)
      if site.can_accept_contributions_changed? && (site.can_accept_contributions == true)
        site.progress_tracker.update_attribute(:fundraising_activated, true)
      end
    end
    
    def check_content_created(item)
      progress_tracker = item.site.progress_tracker
      unless progress_tracker.content_created
        progress_tracker.update_attribute(:content_created, true)
      end
    end
  
end
