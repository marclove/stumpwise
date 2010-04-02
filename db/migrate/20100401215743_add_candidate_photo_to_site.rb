class AddCandidatePhotoToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :candidate_photo, :string
  end

  def self.down
    remove_column :sites, :candidate_photo
  end
end
