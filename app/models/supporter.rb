# == Schema Information
# Schema version: 20100825194538
#
# Table name: supporters
#
#  id                     :integer(4)      not null, primary key
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
#  lat                    :float
#  lng                    :float
#

class Supporter < ActiveRecord::Base
  attr_accessor :address
  
  has_many :supporterships, :foreign_key => 'supporter_id'
  has_many :sites, :through => :supporterships
  has_many :sms_messages, :foreign_key => 'recipient_id'
  has_many :sms_campaigns, :through => :sms_messages
  
  validates_length_of     :email, :within => 6..100,   :allow_blank => true
  validates_format_of     :email, :with => RegEmailOk, :allow_blank => true
  validates_presence_of   :email, :if => Proc.new{|s| s.mobile_phone.blank?}
  validates_uniqueness_of :email
  
  validates_length_of   :phone, :is => 10, :allow_blank => true,
                                :message => 'must include the area code and be 10 digits long'
  validates_length_of   :mobile_phone, :is => 10, :allow_blank => true,
                                :message => 'must include the area code and be 10 digits long'
  
  before_save :geocode
  
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
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def full_address
    returning result = [] do
      result << thoroughfare unless thoroughfare.blank?
      result << last_address_line if last_address_line
    end.join("<br/>")
  end
  
  def last_address_line
    returning result = [] do
      result << locality unless locality.blank?
      result << area_and_postal_code unless area_and_postal_code.blank?
    end
    result.empty? ? nil : result.join(", ")
  end
  
  def area_and_postal_code
    "#{administrative_area} #{postal_code}"
  end
  
  private
    def geocode
      if address.present?
        result = Geokit::Geocoders::MultiGeocoder.geocode(address)
        if result.success? && result.accuracy > 4
          self[:thoroughfare]            = result.street_address
          self[:locality]                = result.city
          self[:subadministrative_area]  = result.province
          self[:administrative_area]     = result.state
          self[:country]                 = result.country_code
          self[:postal_code]             = result.zip
          self[:lat]                     = result.lat
          self[:lng]                     = result.lng
        end
      end
    end
end
