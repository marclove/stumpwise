# == Schema Information
# Schema version: 20100402013401
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

class Article < Item
  belongs_to :blog, :foreign_key => 'parent_id'

  attr_readonly :show_in_navigation
  
  def template
    @template ||= Template.find_by_filename(blog.article_template_name)
  end
  
  def to_liquid
    ArticleDrop.new(self)
  end
end
