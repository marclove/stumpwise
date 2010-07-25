# == Schema Information
# Schema version: 20100725234858
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

class Article < Item
  belongs_to :blog, :foreign_key => 'parent_id'
  attr_readonly :show_in_navigation
  validates_presence_of :parent_id, :body
  before_validation_on_create :set_site
  
  def self.per_page; 5; end
  
  def template
    @template ||= site.theme.templates.first(:conditions => {:filename => blog.article_template_name})
  end
  
  def to_liquid
    ArticleDrop.new(self)
  end
  
  private
    def set_site
      self[:site_id] = blog.site_id if blog
    end
end
