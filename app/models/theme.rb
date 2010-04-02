# == Schema Information
# Schema version: 20100402140216
#
# Table name: themes
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Theme < ActiveRecord::Base
  has_many :sites
  
  has_many :liquid_templates
  has_many :layouts
  has_many :templates
  has_many :assets, :class_name => 'ThemeAsset'
end
