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

class Item < ActiveRecord::Base
  RESERVED_PERMALINKS = ["contribute", "join", "contributions", "contributions/new", "supporters", "supporters/new", "admin"]
  
  acts_as_nested_set(:scope => :site, :dependent => :destroy)
  alias_method :previous, :left_sibling
  alias_method :next,     :right_sibling

  belongs_to :site
  
  before_validation :set_slug, :set_permalink
  after_save :update_permalinks_on_descendants
  after_move :update_permalink, :update_permalinks_on_descendants
  
  validates_presence_of   :title, :slug, :site_id
  validates_uniqueness_of :slug, :scope => [:site_id, :parent_id], :case_sensitive => false
  validates_uniqueness_of :permalink, :scope => :site_id, :case_sensitive => false
  validates_exclusion_of  :permalink, :in => RESERVED_PERMALINKS
  
  
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
    #puts "Updated: was #{permalink}, now #{default_permalink}"
    update_attribute(:permalink, default_permalink)
  end
  
  def destroy
    raise Stumpwise::ParentItemDestroyError unless children.empty?
    super
  end
  
  private
    def set_slug
      return true if !slug.blank?
      self.slug = self.title.parameterize if self.title
    end
    
    def set_permalink
      if self.permalink.blank? || (!new_record? && slug_changed?)
        self.permalink = default_permalink
      end
    end
    
    def default_permalink
      self.parent ? "#{self.parent.permalink}/#{self.slug}" : "#{self.slug}"
    end
    
    def update_permalinks_on_descendants
      self.descendants.each{ |d| d.update_permalink }
    end
end
