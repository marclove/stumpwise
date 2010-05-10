require 'test_helper'

class ContributionTest < ActiveSupport::TestCase
  context "The Contribution class" do
    should_have_class_methods :pending, :approved, :declined, :refunded
    
    should_validate_presence_of :site_id, :first_name, :last_name, :address1,
                                :city, :state, :zip, :country, :occupation,
                                :employer
    
    # Eligibility statement
    should "require confirmation of eligibility if the site has an eligibility statement" do
      c = sites(:with_eligibility_statement).contributions.build(:compliance_confirmation => false)
      assert !c.valid?
      assert c.errors.on(:compliance_confirmation)
      c.compliance_confirmation = true
      c.valid?
      assert_nil c.errors.on(:compliance_confirmation)
    end

    should "not require confirmation of eligibility if the site has no eligibility statement" do
      c = sites(:without_eligibility_statement).contributions.build(:compliance_confirmation => false)
      c.valid?
      assert_nil c.errors.on(:compliance_confirmation)
    end

    # Amount
    should_validate_numericality_of :amount
    should "require amount to be an integer" do
      c = Contribution.make_unsaved(:amount => 1.2)
      c.valid?
      assert c.errors.on(:amount)
    end
    should "require amount to be at least 100 ($1)" do
      c = Contribution.make_unsaved(:amount => 99)
      c.valid?
      assert_match /must be at least \$1\.00/, c.errors.on(:amount)
    end
    
    # Email formatting & uniqueness
    should_ensure_length_in_range :email, 6..100
    should_allow_values_for :email, "a@b.ly", "test@john.co.uk"
    should_not_allow_values_for :email, "notanemail", "no email"

    should "always store email as lower case" do
      s = Contribution.make(:email => "F@FOOBAR.COM")
      s.email.should == 'f@foobar.com'
    end
  end
  
  context "A contribution" do
    should_belong_to :site
    should_have_many :transactions
    
    should "process a contribution successfully" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')
      
      assert_difference 'contribution.transactions.count' do
        authorization = contribution.process(credit_card)
        assert_equal authorization.reference, contribution.authorization_reference
        assert authorization.success?
        assert contribution.approved?
      end
    end
    
    should "process a declined contribution" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '2')
      
      assert_difference 'contribution.transactions.count' do
        authorization = contribution.process(credit_card)
        assert_nil contribution.authorization_reference
        assert !authorization.success?
        assert contribution.declined?
      end
    end

    should "survive an exception raised during authorization" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '3')
      
      assert_difference 'contribution.transactions.count' do
        authorization = contribution.process(credit_card)
        assert_nil contribution.authorization_reference
        assert !authorization.success?
        assert contribution.declined?
      end
    end

    should "refund a contribution successfully" do
      contribution = contributions(:approved)

      assert_difference 'contribution.transactions.count' do
        authorization = contribution.refund
        assert authorization.success?
        assert contribution.refunded?
      end
    end
    
    should "set the order_id when processing is attempted" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')

      assert_blank contribution.order_id
      contribution.process(credit_card)
      assert_not_blank contribution.order_id
    end
    
    should "set the card type when processing is attempted" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')

      assert_blank contribution.card_type
      contribution.process(credit_card)
      assert_equal "visa", contribution.card_type
    end
    
    should "set the card display number when processing is attempted" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')

      assert_blank contribution.card_display_number
      contribution.process(credit_card)
      assert_equal "XXXX-XXXX-XXXX-1", contribution.card_display_number
    end
    
    should "set the compliance statement when processing is attempted" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')

      assert_blank contribution.compliance_statement
      contribution.process(credit_card)
      assert_equal "statement", contribution.compliance_statement
    end
    
    should "set the card year when processing is attempted" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')

      assert_blank contribution.card_year
      contribution.process(credit_card)
      assert_equal (Time.now.year + 1), contribution.card_year
    end
    
    should "set the card month when processing is attempted" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')

      assert_blank contribution.card_month
      contribution.process(credit_card)
      assert_equal 1, contribution.card_month
    end
    
    should "record whether its a test contribution when processing is attempted" do
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')

      assert_blank contribution.test
      contribution.process(credit_card)
      assert_equal true, contribution.test
    end
    
    should "have a decimal version of its amount as display amount" do
      assert_equal 20.0, contributions(:approved).display_amount
    end
    
    should "know its contributor's full name" do
      assert_equal "Marc Love", contributions(:approved).contributor_name
    end
    
    should "know its contributor's full name and email" do
      assert_equal "Marc Love <me@me.com>", contributions(:approved).contributor_name_with_email
    end
    
    should "know its card information in a displayable format" do
      assert_equal "Visa XXXX-XXXX-XXXX-1234", contributions(:approved).card_information
    end
    
    should "return a hash of default options for ActiveMerchant" do
      expected_hash = {
        :order_id => "e1b949f653fcb52b8c93dc5b37e11277",
        :ip => "99.99.99.99",
        :customer => "Marc Love <me@me.com>",
        :merchant => "Anthony Woods For Congress",
        :description => "Contribution to Anthony Woods For Congress",
        :email => "me@me.com",
        :billing_address => {
          :name => "Marc Love",
          :address1 => "2400 Market Street",
          :address2 => "Suite 1000",
          :city => "San Francisco",
          :state => "CA",
          :country => "US",
          :zip => "94114",
          :phone => "4085555555"
        }
      }
      assert_equal expected_hash, contributions(:approved).default_options
    end
    
    should "trigger the sending of an email receipt when successfully processed" do
      Contribution.any_instance.expects(:send_receipt).returns(true)
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '1')
      contribution.process(credit_card)
    end

    should "not trigger the sending of an email receipt when processing is declined" do
      Contribution.any_instance.expects(:send_receipt).never
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '2')
      contribution.process(credit_card)
    end

    should "not trigger the sending of an email receipt when an error is raised while processing" do
      Contribution.any_instance.expects(:send_receipt).never
      contribution = contributions(:pending)
      credit_card = credit_card(:number => '3')
      contribution.process(credit_card)
    end
  end
end
