# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# == Schema Information
# Schema version: 20100916062732
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

class Blog < Item
  has_many :articles, :class_name => 'Article', :foreign_key => 'parent_id',
                      :order => 'lft DESC', :dependent => :destroy
  
  validates_presence_of :template_name
  validates_presence_of :article_template_name
  
  def initialize(attrs = {})
    super(attrs.reverse_merge({:template_name => 'blog.tpl', :article_template_name => 'article.tpl'}))
  end
  
  def template
    @template ||= site.theme.templates.first(:conditions => {:filename => template_name})
  end
  
  def to_liquid
    BlogDrop.new(self)
  end
end
