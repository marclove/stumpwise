# == Schema Information
# Schema version: 20100612013511
#
# Table name: administratorships
#
#  id               :integer(4)      not null, primary key
#  administrator_id :integer(4)
#  site_id          :integer(4)
#

class Administratorship < ActiveRecord::Base
  belongs_to :administrator, :class_name => 'User'
  belongs_to :site
  validates_presence_of :administrator_id, :site_id
end
