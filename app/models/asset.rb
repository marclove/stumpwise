# == Schema Information
# Schema version: 20100725234858
#
# Table name: assets
#
#  id         :integer(4)      not null, primary key
#  site_id    :integer(4)
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Asset < ActiveRecord::Base
  belongs_to :site
  validates_presence_of :site_id
  mount_uploader :file, SiteAssetUploader
end
