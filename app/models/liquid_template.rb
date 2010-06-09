# == Schema Information
# Schema version: 20100612013511
#
# Table name: liquid_templates
#
#  id         :integer(4)      not null, primary key
#  theme_id   :integer(4)      not null
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
  validates_proper_liquid_syntax :content

  def parsed
    Liquid::Template.parse(self.content)
  end
end
