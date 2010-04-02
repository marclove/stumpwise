# == Schema Information
# Schema version: 20100401215743
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

class Template < LiquidTemplate
end
