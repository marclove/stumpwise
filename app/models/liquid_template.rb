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

  def parsed
    Liquid::Template.parse(self.content)
  end
end
