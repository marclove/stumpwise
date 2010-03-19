# == Schema Information
# Schema version: 20100316133950
#
# Table name: supporters
#
#  id                     :integer         not null, primary key
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)     not null
#  name_prefix            :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  name_suffix            :string(255)
#  phone                  :string(255)
#  thoroughfare           :string(255)
#  locality               :string(255)
#  subadministrative_area :string(255)
#  administrative_area    :string(255)
#  country                :string(255)
#  postal_code            :string(255)
#

class Supporter < ActiveRecord::Base
  RegEmailName   = '[\w\.%\+\-]+'
  RegDomainHead  = '(?:[A-Z0-9\-]+\.)+'
  RegDomainTLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RegEmailOk     = /\A#{RegEmailName}@#{RegDomainHead}#{RegDomainTLD}\z/i
  
  has_many :supporterships, :foreign_key => 'supporter_id'
  has_many :sites, :through => :supporterships
  
  validates_length_of :email, :within => 6..100, :allow_blank => false
  validates_format_of :email, :with => RegEmailOk, :allow_blank => false
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end
end
