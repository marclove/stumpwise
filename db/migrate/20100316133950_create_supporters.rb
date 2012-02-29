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

class CreateSupporters < ActiveRecord::Migration
  def self.up
    create_table :supporters do |t|
      t.timestamps
      t.string    :email, :null => false
      t.string    :name_prefix
      t.string    :first_name
      t.string    :last_name
      t.string    :name_suffix
      t.string    :phone
      t.string    :thoroughfare
      t.string    :locality
      t.string    :subadministrative_area
      t.string    :administrative_area
      t.string    :country
      t.string    :postal_code
    end
    add_index :supporters, :email, :unique => true
    add_index :supporters, [:last_name, :first_name]
  end

  def self.down
    drop_table :supporters
  end
end
