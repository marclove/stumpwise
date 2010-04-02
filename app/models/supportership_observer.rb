class SupportershipObserver < ActiveRecord::Observer
  observe :supportership
  
  def before_create(supportership)
    if supportership.receive_email && supportership.supporter.email
      supportership.site.supporter_list.add_and_resubscribe(supportership.supporter.email)
    end
  end
  
  def before_update(supportership)
    if supportership.receive_email_changed? && supportership.supporter.email
      if supportership.receive_email #subscribing
        supportership.site.supporter_list.add_and_resubscribe(supportership.supporter.email)        
      else # unsubscribing
        supportership.site.supporter_list.remove_subscriber(supportership.supporter.email)
      end
    end
  end
  
  def before_destroy(supportership)
    if supportership.supporter.email
      supportership.site.supporter_list.remove_subscriber(supportership.supporter.email)
    end
  end
end