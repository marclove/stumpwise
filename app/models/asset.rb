# == Schema Information
# Schema version: 20100316133950
#
# Table name: assets
#
#  id                 :integer         not null, primary key
#  site_id            :string(255)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Asset < ActiveRecord::Base
  belongs_to :site
  
  has_attached_file :photo, :styles => {
    :w140 => "140x>", :w300 => "300x>",
    :w460 => "460x>", :w620 => "620x>"
  }
  validates_attachment_presence :photo
end
