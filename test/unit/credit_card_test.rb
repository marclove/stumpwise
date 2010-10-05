require 'test_helper'

class CreditCardTest < ActiveSupport::TestCase
  context "Credit Card" do
    setup do
      @cc_hash = {
        :number => "4111111111111111",
        :cvv => "123",
        :expiration_month => "12",
        :expiration_year => (Time.now.year + 1).to_s
      }
      @cc = CreditCard.new(@cc_hash)
    end
    
    should "allow initialization without arguments" do
      assert_nothing_thrown do
        CreditCard.new()
      end
    end
    
    should "have a token attribute" do
      assert @cc.respond_to?(:token)
    end
    
    should "have a number attribute" do
      assert @cc.respond_to?(:number)
    end
    
    should "have a cvv attribute" do
      assert @cc.respond_to?(:cvv)
    end
    
    should "have an expiration_month attribute" do
      assert @cc.respond_to?(:expiration_month)
    end
    
    should "have an expiration_year attribute" do
      assert @cc.respond_to?(:expiration_year)
    end
    
    should "validate the presence of :number" do
      @cc.number = ""
      assert !@cc.valid?
      assert @cc.errors.on(:number)
    end
    
    should "validate the presence of :cvv" do
      @cc.cvv = ""
      assert !@cc.valid?
      assert @cc.errors.on(:cvv)
    end
    
    should "validate the presence of :expiration_month" do
      @cc.expiration_month = ""
      assert !@cc.valid?
      assert @cc.errors.on(:expiration_month)
    end
    
    should "validate the presence of :expiration_year" do
      @cc.expiration_year = ""
      assert !@cc.valid?
      assert @cc.errors.on(:expiration_year)
    end
    
    should "not freak out if :number has dashes in it" do
      @cc.number = "4111-1111-1111-1111"
      assert @cc.valid?
      assert_equal "4111111111111111", @cc.number
    end
    
    should "validate the length of :number is at least 12" do
      @cc.number = "41111111111"
      assert !@cc.valid?
      assert @cc.errors.on(:number)
    end
    
    should "validate the :number using a checksum" do
      @cc.number = "1111111111111111"
      assert !@cc.valid?
      assert @cc.errors.on(:number)
    end
    
    should "validate the length of the :expiration_year is 4" do
      @cc.expiration_year = "123"
      assert !@cc.valid?
      assert @cc.errors.on(:expiration_year)
    end
    
    should "mark card as invalid when card expiration date is last month" do
      last_month = Time.now.utc.prev_month
      @cc.expiration_month = last_month.month.to_s
      @cc.expiration_year = last_month.year.to_s
      assert !@cc.valid?
      assert @cc.errors.on(:expiration_month)
      assert @cc.errors.on(:expiration_year)
    end
    
    should "mark card as valid when card expiration date is this month" do
      this_month = Time.now.utc
      @cc.expiration_month = this_month.month.to_s
      @cc.expiration_year = this_month.year.to_s
      assert @cc.valid?
    end
    
    should "mark card as valid when card expiration date is next month" do
      next_month = Time.now.utc.next_month
      @cc.expiration_month = next_month.month.to_s
      @cc.expiration_year = next_month.year.to_s
      assert @cc.valid?
    end
    
    should "return a hash of itself" do
      assert_equal @cc_hash.symbolize_keys, @cc.to_hash.symbolize_keys
    end
    
    should "return a hash of itself that includes the token if token is present" do
      new_hash = @cc_hash.merge(:token => "mytoken")
      @cc = CreditCard.new(new_hash)
      assert_equal new_hash.symbolize_keys, @cc.to_hash.symbolize_keys
    end
  end
end