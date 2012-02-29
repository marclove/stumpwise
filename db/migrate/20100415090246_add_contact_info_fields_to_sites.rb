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

class AddContactInfoFieldsToSites < ActiveRecord::Migration
  def self.up
    change_table :sites do |t|
      t.string :campaign_legal_name
      t.string :campaign_street
      t.string :campaign_city
      t.string :campaign_state
      t.string :campaign_zip
      t.rename :public_phone, :campaign_phone
      t.rename :public_email, :campaign_email
    end
  end

  def self.down
    change_table :sites do |t|
      t.remove :campaign_legal_name
      t.remove :campaign_street
      t.remove :campaign_city
      t.remove :campaign_state
      t.remove :campaign_zip
      t.rename :campaign_phone, :public_phone
      t.rename :campaign_email, :public_email
    end
  end
end
