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
# Table name: contribution_transactions
#
#  id              :integer(4)      not null, primary key
#  contribution_id :integer(4)
#  amount          :integer(4)
#  success         :boolean(1)
#  reference       :string(255)
#  message         :string(255)
#  action          :string(255)
#  params          :text
#  test            :boolean(1)
#  created_at      :datetime
#  updated_at      :datetime
#

class ContributionTransaction < ActiveRecord::Base
  belongs_to :contribution
  serialize :params
 
  class << self
    def approve(amount, credit_card, options = {})
      process('approve', amount) do |gw|
        gw.purchase(amount, credit_card, options)
      end
    end
    
    def refund(amount, authorization, options = {})
      process('refund', amount) do |gw|
        gw.credit(amount, authorization, options)
      end
    end
    
    private
      def process(action, amount = nil)
      end
  end
end
