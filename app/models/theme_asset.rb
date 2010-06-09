# == Schema Information
# Schema version: 20100612013511
#
# Table name: theme_assets
#
#  id       :integer(4)      not null, primary key
#  theme_id :integer(4)
#  file     :string(255)
#

class ThemeAsset < ActiveRecord::Base
  belongs_to :theme
  validates_presence_of :theme_id
  mount_uploader :file, ThemeAssetUploader
end
