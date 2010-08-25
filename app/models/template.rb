# == Schema Information
# Schema version: 20100817131545
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

class Template < LiquidTemplate
end
