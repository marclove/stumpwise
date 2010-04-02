# == Schema Information
# Schema version: 20100402013401
#
# Table name: assets
#
#  id         :integer         not null, primary key
#  site_id    :integer
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Asset < ActiveRecord::Base
  belongs_to :site
  #has_attachment :storage => :s3, :path_prefix => "sites"
  validates_presence_of :site_id
  mount_uploader :file, SiteAssetUploader

=begin
  # provides a path like: sites/:site_id/:filename
  def attachment_path_id
    site_id.to_s
  end
=end
end
