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

class ImproveIndexesOnItems < ActiveRecord::Migration
  def self.up
    remove_index :items, :column => [:lft, :rgt, :parent_id, :site_id]
    
    add_index :items, [:parent_id, :published, :type, :lft], :name => :by_parent_published_type_and_lft
    
    remove_index :items, :column => [:parent_id, :site_id]
    add_index :items, [:site_id, :parent_id, :published, :show_in_navigation], :name => :by_site_parent_published_and_nav
    
    remove_index :items, :column => [:site_id, :published, :permalink]
    add_index :items, [:permalink, :site_id, :published], :name => :by_permalink_site_and_published
  end

  def self.down
    add_index :items, [:lft, :rgt, :parent_id, :site_id]
    
    remove_index :items, :name => :by_parent_published_type_and_lft
    
    add_index :items, [:parent_id, :site_id]
    remove_index :items, :name => :by_site_parent_published_and_nav
    
    add_index :items, [:site_id, :published, :permalink]
    remove_index :items, :name => :by_permalink_site_and_published
  end
end
