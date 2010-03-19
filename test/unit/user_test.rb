require 'test_helper'
 
class UserTest < ActiveSupport::TestCase
  should "validate presence of email" do
    user = User.new
    user.valid?
    assert user.errors.on(:email)
    user.email = 'foo@bar.com'
    user.valid?
    assert !user.errors.on(:email)
  end
  
  should "validate length of email" do
    user = User.new
    user.email = 'a@a'
    user.valid?
    assert user.errors.on(:email)
    user.email = 'r@a.wk'
    user.valid?
    assert !user.errors.on(:email)
  end
  
  should "always store email as lower case" do
    user = User.new
    user.email = 'F@FOOBAR.COM'
    user.email.should == 'f@foobar.com'
  end
  
  should "be able to set user's reset password code" do
    user = User.make
    user.reset_password_code.should be_nil
    user.reset_password_code_until.should be_nil
    user.set_password_code!
    user.reset_password_code.should_not be_nil
    user.reset_password_code_until.should_not be_nil
  end
  
  context "Authentication" do
    should 'work with existing email and correct password' do
      user = User.make
      User.authenticate(user.email, 'testing').should == user
    end
    
    should 'work with existing email (case insensitive) and password' do
      user = User.make
      User.authenticate(user.email.upcase, 'testing').should == user
    end
    
    should 'not work with existing email and incorrect password' do
      User.authenticate('john@doe.com', 'foobar').should be_nil
    end
    
    should 'not work with non-existant email' do
      User.authenticate('foo@bar.com', 'foobar').should be_nil
    end
  end
  
  context "password" do
    should 'be required if crypted password is blank' do
      user = User.new
      user.valid?
      assert user.errors.on(:password)
    end
    
    should 'not be required if crypted password is present' do
      user = User.new
      user.crypted_password = BCrypt::Password.create('foobar')
      user.valid?
      assert !user.errors.on(:password)
    end
    
    should "validate the length of password" do
      user = User.new
      user.password = '1234'
      user.valid?
      assert user.errors.on(:password)
      user.password = '123456'
      user.valid?
      assert !user.errors.on(:password)
    end
  end
end