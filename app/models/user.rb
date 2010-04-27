# == Schema Information
# Schema version: 20100426155751
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  email               :string(255)     not null
#  first_name          :string(255)
#  last_name           :string(255)
#  crypted_password    :string(255)
#  password_salt       :string(255)
#  persistence_token   :string(255)     not null
#  single_access_token :string(255)
#  perishable_token    :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  login_count         :integer         default(0), not null
#  failed_login_count  :integer         default(0), not null
#  last_request_at     :datetime
#  current_login_at    :datetime
#  last_login_at       :datetime
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#  super_admin         :boolean
#  time_zone           :string(255)     default("Pacific Time (US & Canada)")
#

class User < ActiveRecord::Base
  attr_protected :super_admin
  
  acts_as_authentic do |c|
    c.merge_validates_length_of_password_field_options :minimum => 8
  end
  
  has_many :owned_sites,        :foreign_key => 'owner_id', :class_name => 'Site'
  has_many :administratorships, :foreign_key => 'administrator_id'
  has_many :administered_sites, :through => :administratorships, :source => :site
  
  validates_length_of :email, :within => 6..100, :allow_blank => false
  validates_format_of :email, :with => RegEmailOk, :allow_blank => false
  validates_presence_of :first_name, :last_name, {:message => "is required"}
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end
  
  def name
    "#{first_name} #{last_name}"
  end
end
