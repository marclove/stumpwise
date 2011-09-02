module FlashMessagesHelper
  def flash_messages
    unless error_flash.blank? && notice_flash.blank?
      content_tag :div, :id => 'flash_messages' do
        error_flash + notice_flash
      end
    end
  end
  
  private
    def error_flash
      if flash[:error]
        content_tag :p, flash[:error], {:id => 'error', :class => 'flash_message'}
      else
        ''.html_safe
      end
    end

    def notice_flash
      if flash[:notice]
        content_tag :p, flash[:notice], {:id => 'notice', :class => 'flash_message'}
      else
        ''.html_safe
      end
    end
end
