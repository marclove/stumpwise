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

class CreateContributions < ActiveRecord::Migration
  def self.up
    create_table :contributions do |t|
      t.integer   :site_id
      t.string    :order_id
      t.timestamps
      t.string    :email
      t.integer   :amount
      t.string    :status
      t.string    :ip
      t.string    :employer
      t.string    :occupation
      t.boolean   :compliance_confirmation
      t.text      :compliance_statement
      t.string    :first_name
      t.string    :last_name
      t.string    :card_type
      t.string    :card_display_number
      t.integer   :card_month
      t.integer   :card_year
      t.string    :address1
      t.string    :address2
      t.string    :city
      t.string    :state
      t.string    :country
      t.string    :zip
      t.string    :phone
      t.boolean   :success
      t.boolean   :test
      t.boolean   :fraud_review
      t.text      :message
      t.string    :authorization
      t.text      :cvv_result
      t.text      :avs_result
    end
    
    add_index :contributions, :site_id
    add_index :contributions, :order_id, :unique => true
    add_index :contributions, :email
    add_index :contributions, :status
    add_index :contributions, [:last_name, :first_name]
    add_index :contributions, :success
  end

  def self.down
    drop_table :contributions
  end
end
