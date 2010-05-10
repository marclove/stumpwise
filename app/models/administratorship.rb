# == Schema Information
# Schema version: 20100503085721
#
# Table name: administratorships
#
#  id               :integer         not null, primary key
#  administrator_id :integer
#  site_id          :integer
#

class Administratorship < ActiveRecord::Base
  belongs_to :administrator, :class_name => 'User'
  belongs_to :site
end
