require 'test_helper'

class SupporterTest < ActiveSupport::TestCase
  context "The Supporter class" do
    setup do
      @existing = Supporter.make
    end
    
    # Email formatting & uniqueness
    should_ensure_length_in_range :email, 6..100
    should_allow_values_for :email, "a@b.ly", "test@john.co.uk"
    should_not_allow_values_for :email, "notanemail", "no email"
    should_validate_uniqueness_of :email, :case_sensitive => false

    should "always store email as lower case" do
      s = Supporter.make(:email => "F@FOOBAR.COM")
      s.email.should == 'f@foobar.com'
    end
    
    should_eventually "validate the presence of email if mobile phone is blank"
    should_eventually "validate the presence of mobile phone if email is blank"
    should_eventually "validate the length of the phone number to be 10"
    should_eventually "validate the length of the mobile phone to be 10"
    should_eventually "strip the phone number of any whitespace or formatting"
    should_eventually "strip the mobile phone of any whitespace or formatting"
  end
  
  context "A supporter" do
    should_have_many :supporterships, :sites
    
    should "know its full name" do
      s = Supporter.make(:first_name => "Marc", :last_name => "Love")
      assert_equal "Marc Love", s.name
    end
  end  
end
