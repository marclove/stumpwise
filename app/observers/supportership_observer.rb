class SupportershipObserver < ActiveRecord::Observer
  observe :supportership
  
  def after_create(supportership)
    if supportership.receive_email && supportership.supporter.email
      if list = supportership.site.supporter_list
        list.add_and_resubscribe(supportership.supporter.email)
      end
    end
  end
  
  def before_update(supportership)
    if supportership.receive_email_changed? && supportership.supporter.email
      if list = supportership.site.supporter_list
        if supportership.receive_email #subscribing
          list.add_and_resubscribe(supportership.supporter.email)        
        else # unsubscribing
          list.remove_subscriber(supportership.supporter.email)
        end
      end
    end
  end
  
  def before_destroy(supportership)
    if supportership.supporter.email
      if list = supportership.site.supporter_list
        list.remove_subscriber(supportership.supporter.email)
      end
    end
  end
end