# == Schema Information
# Schema version: 20100503085721
#
# Table name: theme_assets
#
#  id       :integer         not null, primary key
#  theme_id :integer
#  file     :string(255)
#

class ThemeAsset < ActiveRecord::Base
  belongs_to :theme
  validates_presence_of :theme_id
  mount_uploader :file, ThemeAssetUploader
end
