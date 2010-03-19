# == Schema Information
# Schema version: 20100316133950
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

class Item < ActiveRecord::Base
  RESERVED_PERMALINKS = ["contribute", "join", "contributions/new", "supporters/new", "admin"]
  
  acts_as_nested_set :scope => :site
  alias_method :previous, :left_sibling
  alias_method :next,     :right_sibling

  belongs_to :site
  belongs_to :parent, :class_name => 'Item'
  has_many :children, :class_name => 'Item', :foreign_key => 'parent_id', :order => 'lft ASC'
  
  before_validation :set_slug, :set_permalink
  after_save        :update_permalinks_on_descendants
  before_destroy    :ensure_not_parent
  
  validates_presence_of   :title, :message => "A title is required."
  validates_presence_of   :slug,  :message => "A permalink is required."
  validates_uniqueness_of :slug, :scope => [:site_id, :parent_id],
                          :case_sensitive => false,
                          :message => "An item on your site is already using this permalink."
  validates_uniqueness_of :permalink, :scope => :site_id,
                          :case_sensitive => false,
                          :message => "An item on your site is already using this permalink."
  validates_exclusion_of  :permalink, :in => RESERVED_PERMALINKS,
                          :message => "This is a reserved permalink. Please change it to something else."
  
  
  def liquid_name
    self.class.name.underscore
  end
  
  def landing_page?
    parent_id.nil? && lft == 1
  end
  
  def to_liquid
    ItemDrop.new(self)
  end
  
  def update_permalink
    self.update_attributes({:permalink => default_permalink})
  end
  
  private
    def ensure_not_parent
      children.size == 0
    end
  
    def set_slug
      return true if !slug.blank?
      self.slug = self.title.parameterize if self.title
    end
    
    def set_permalink
      self.permalink = default_permalink
    end
    
    def default_permalink
      self.parent ? "#{self.parent.permalink}/#{self.slug}" : "#{self.slug}"
    end
    
    def update_permalinks_on_descendants
      self.descendants.each{ |d| d.update_permalink }
    end
end
