# == Schema Information
# Schema version: 20100503085721
#
# Table name: liquid_templates
#
#  id         :integer         not null, primary key
#  theme_id   :integer         not null
#  type       :string(255)     not null
#  filename   :string(255)     not null
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

class LiquidTemplate < ActiveRecord::Base
  belongs_to :theme
  validates_presence_of :theme_id, :type, :filename
  validates_uniqueness_of :filename, :scope => [:theme_id]

  def parsed
    Liquid::Template.parse(self.content)
  end
end
