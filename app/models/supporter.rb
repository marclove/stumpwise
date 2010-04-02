# == Schema Information
# Schema version: 20100401215743
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
#  mobile_phone           :string(255)
#

class Supporter < ActiveRecord::Base
  has_many :supporterships, :foreign_key => 'supporter_id'
  has_many :sites, :through => :supporterships
  
  validates_length_of   :email, :within => 6..100,   :allow_blank => true
  validates_format_of   :email, :with => RegEmailOk, :allow_blank => true
  validates_presence_of :email, :if => Proc.new{|s| s.mobile_phone.blank?}
  validates_length_of   :phone, :is => 10, :allow_blank => true,
                                :message => 'must include the area code and be 10 digits long'
  validates_length_of   :mobile_phone, :is => 10, :allow_blank => true,
                                :message => 'must include the area code and be 10 digits long'
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end
  
  def phone=(new_phone)
    new_phone = new_phone.gsub(/[^0-9]/, '') unless new_phone.nil?
    write_attribute(:phone, new_phone)
  end
  
  def mobile_phone=(new_mobile_phone)
    new_mobile_phone = new_mobile_phone.gsub(/[^0-9]/, '') unless new_mobile_phone.nil?
    write_attribute(:mobile_phone, new_mobile_phone)
  end
end
