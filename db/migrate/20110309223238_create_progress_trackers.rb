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

class CreateProgressTrackers < ActiveRecord::Migration
  def self.up
    create_table :progress_trackers do |t|
      t.belongs_to :site
      t.boolean :theme_customized, :contact_info_entered, 
                :candidate_photo_uploaded, :social_networks_added,
                :custom_domain_setup, :content_created,
                :fundraising_activated, :default => true
      t.timestamps
    end
    
    Site.all.each{|s| s.create_progress_tracker }
    
    change_column_default :progress_trackers, :theme_customized, false
    change_column_default :progress_trackers, :contact_info_entered, false
    change_column_default :progress_trackers, :candidate_photo_uploaded, false
    change_column_default :progress_trackers, :social_networks_added, false
    change_column_default :progress_trackers, :custom_domain_setup, false
    change_column_default :progress_trackers, :content_created, false
    change_column_default :progress_trackers, :fundraising_activated, false
  end

  def self.down
    drop_table :progress_trackers
  end
end
