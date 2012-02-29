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

class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.timestamps
      t.string  :type
      t.integer :created_by
      t.integer :updated_by
      
      # acts_as_nested_set
      t.integer :site_id
      t.integer :parent_id
      t.integer :lft, :rgt

      t.string  :title
      t.string  :slug
      t.string  :permalink
      t.boolean :published, :default => false
      t.boolean :show_in_navigation, :default => false
      t.string  :template_name
    end
    
    add_index :items, [:site_id, :published, :permalink]
    add_index :items, [:parent_id, :site_id]
    add_index :items, [:lft, :rgt, :parent_id, :site_id]
  end

  def self.down
    drop_table :items
  end
end
