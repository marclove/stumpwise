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
# Table name: campaign_statements
#
#  id              :integer(4)      not null, primary key
#  site_id         :integer(4)
#  disbursed_on    :date
#  funds_available :date
#  starting        :datetime
#  ending          :datetime
#  total_raised    :decimal(8, 2)   default(0.0)
#  total_fees      :decimal(8, 2)   default(0.0)
#  total_due       :decimal(8, 2)   default(0.0)
#  created_at      :datetime
#  updated_at      :datetime
#

class CampaignStatement < ActiveRecord::Base
  belongs_to :site
  has_many :contributions
end
