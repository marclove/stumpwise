# == Schema Information
# Schema version: 20100825194538
#
# Table name: supporterships
#
#  id            :integer(4)      not null, primary key
#  supporter_id  :integer(4)
#  site_id       :integer(4)
#  receive_email :boolean(1)
#  receive_sms   :boolean(1)
#  created_at    :datetime
#  updated_at    :datetime
#

class Supportership < ActiveRecord::Base
  belongs_to :supporter
  belongs_to :site
  validates_presence_of :supporter_id, :site_id
end
