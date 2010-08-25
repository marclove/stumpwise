# == Schema Information
# Schema version: 20100817131545
#
# Table name: items
#
#  id                    :integer(4)      not null, primary key
#  created_at            :datetime
#  updated_at            :datetime
#  type                  :string(255)
#  created_by            :integer(4)
#  updated_by            :integer(4)
#  site_id               :integer(4)
#  parent_id             :integer(4)
#  lft                   :integer(4)
#  rgt                   :integer(4)
#  title                 :string(255)
#  slug                  :string(255)
#  permalink             :string(255)
#  published             :boolean(1)
#  show_in_navigation    :boolean(1)
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
    @template ||= site.theme.templates.first(:conditions => {:filename => template_name})
  end
  
  def to_liquid
    PageDrop.new(self)
  end
end
