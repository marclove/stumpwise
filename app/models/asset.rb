# == Schema Information
# Schema version: 20100416182257
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
  validates_presence_of :site_id
  mount_uploader :file, SiteAssetUploader
end
