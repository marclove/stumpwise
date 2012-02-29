# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
