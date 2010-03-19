# == Schema Information
# Schema version: 20100316133950
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
#

class User < ActiveRecord::Base
  acts_as_authentic
  
  RegEmailName   = '[\w\.%\+\-]+'
  RegDomainHead  = '(?:[A-Z0-9\-]+\.)+'
  RegDomainTLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RegEmailOk     = /\A#{RegEmailName}@#{RegDomainHead}#{RegDomainTLD}\z/i
  
  has_many :owned_sites,        :foreign_key => 'owner_id'
  has_many :administratorships, :foreign_key => 'administrator_id'
  has_many :administered_sites, :through => :administratorships, :source => :site
  
  validates_length_of :email, :within => 6..100, :allow_blank => false
  validates_format_of :email, :with => RegEmailOk, :allow_blank => false
  
  # PasswordRequired = Proc.new { |u| u.password_required? }
  # validates_presence_of     :password, :if => PasswordRequired
  # validates_confirmation_of :password, :if => PasswordRequired, :allow_nil => true
  # validates_length_of       :password, :if => PasswordRequired, :allow_nil => true, :minimum => 6
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end
  
  # def password_required?
  #   crypted_password.blank? || !password.blank?
  # end
end
