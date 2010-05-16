require 'test_helper'

class UserDropTest < ActiveSupport::TestCase
  context "User Drop" do
    setup do
      @user_drop = users(:admin).to_liquid
    end
    
    should "have a name attribute" do
      assert_equal "Jeff Such", @user_drop['name']
    end
    
    should "have an email attribute" do
      assert_equal "jeff@anthonywoods.com", @user_drop['email']
    end
    
    should "have a first name attribute" do
      assert_equal "Jeff", @user_drop['first_name']
    end
    
    should "have a last name attribute" do
      assert_equal "Such", @user_drop['last_name']
    end
  end
end