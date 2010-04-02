# == Schema Information
# Schema version: 20100401215743
#
# Table name: theme_assets
#
#  id       :integer         not null, primary key
#  theme_id :integer
#  file     :string(255)
#

class ThemeAsset < ActiveRecord::Base
=begin
  def self.path_prefix
    "themes"
  end
  
  def self.base_url
    @base_url ||= File.join(
      Technoweenie::AttachmentFu::Backends::S3Backend.protocol +
      Technoweenie::AttachmentFu::Backends::S3Backend.hostname +
      Technoweenie::AttachmentFu::Backends::S3Backend.port_string,
      ThemeAsset.new.s3_config[:bucket_name],
      self.path_prefix
    )
  end
=end
  
  belongs_to :theme
  #has_attachment :storage => :s3, :path_prefix => path_prefix
  validates_presence_of :theme_id
  mount_uploader :file, ThemeAssetUploader
  
=begin
  # provides a path like: themes/:theme_id/:filename
  def attachment_path_id
    theme_id.to_s
  end
=end
end
