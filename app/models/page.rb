# == Schema Information
# Schema version: 20100503085721
#
# Table name: items
#
#  id                    :integer         not null, primary key
#  created_at            :datetime
#  updated_at            :datetime
#  type                  :string(255)
#  created_by            :integer
#  updated_by            :integer
#  site_id               :integer
#  parent_id             :integer
#  lft                   :integer
#  rgt                   :integer
#  title                 :string(255)
#  slug                  :string(255)
#  permalink             :string(255)
#  published             :boolean
#  show_in_navigation    :boolean
#  template_name         :string(255)
#  body                  :text
#  article_template_name :string(255)
#

class Page < Item
  validates_presence_of :template_name
  validates_presence_of :body
  
  def initialize(attrs = {})
    super(attrs.reverse_merge({:template_name => 'page.tpl'}))
  end

  def template
    @template ||= Template.find_by_filename(template_name)
  end
  
  def to_liquid
    PageDrop.new(self)
  end
end
