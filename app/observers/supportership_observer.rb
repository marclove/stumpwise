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