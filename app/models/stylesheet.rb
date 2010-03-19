# == Schema Information
# Schema version: 20100316133950
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

class Stylesheet < LiquidTemplate
end
