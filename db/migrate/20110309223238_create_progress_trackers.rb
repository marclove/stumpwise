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
