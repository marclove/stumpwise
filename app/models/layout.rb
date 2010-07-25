# == Schema Information
# Schema version: 20100725234858
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

class Layout < LiquidTemplate
end
