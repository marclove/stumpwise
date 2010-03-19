# == Schema Information
# Schema version: 20100316133950
#
# Table name: supporterships
#
#  id            :integer         not null, primary key
#  supporter_id  :integer
#  site_id       :integer
#  receive_email :boolean
#

class Supportership < ActiveRecord::Base
  belongs_to :supporter
  belongs_to :site
end
