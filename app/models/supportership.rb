# == Schema Information
# Schema version: 20100426155751
#
# Table name: supporterships
#
#  id            :integer         not null, primary key
#  supporter_id  :integer
#  site_id       :integer
#  receive_email :boolean
#  receive_sms   :boolean
#

class Supportership < ActiveRecord::Base
  belongs_to :supporter
  belongs_to :site
end
