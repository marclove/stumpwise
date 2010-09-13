require 'test_helper'

class ContributionTest < ActiveSupport::TestCase
  context "Contribution" do
    should_have_class_methods :pending, :approved, :declined, :refunded
    should_belong_to :site
    should_have_many :transactions
    
    context "validations" do
      should_validate_presence_of :site_id, :first_name, :last_name, :address1,
                                  :city, :state, :zip, :country, :occupation,
                                  :employer
      
      # Eligibility Statement
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
      should "require amount to be at least 1.00" do
        c = Contribution.make_unsaved(:amount => 0.99)
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
    end # validations
    
    should "know its contributor's full name" do
      assert_equal "Marc Love", contributions(:approved).contributor_name
    end
    
    should "know its contributor's full name and email" do
      assert_equal "Marc Love <me@me.com>", contributions(:approved).contributor_name_with_email
    end
    
    should "know its card information in a displayable format" do
      assert_equal "Visa XXXX-XXXX-XXXX-1234", contributions(:approved).card_information
    end
    
    should "have a transaction processing fee equal to 5% + $0.50" do
      assert_equal BigDecimal.new("5.5"), Contribution.new(:amount => 100.00).transaction_processing_fee
      # rounds up $123.50 * 0.05 = $6.175 + $0.50
      assert_equal BigDecimal.new("6.68"), Contribution.new(:amount => 123.50).transaction_processing_fee
      # rounds down $123.45 * 0.05 = $6.1725 + $0.50
      assert_equal BigDecimal.new("6.67"), Contribution.new(:amount => 123.45).transaction_processing_fee
    end
    
    context "incrementing the processing fees" do
      should "increase the processing_fees by the #transaction_processing_fee" do
        assert_equal 0.0, contributions(:pending).processing_fees
        contributions(:pending).send(:increment_processing_fees)
        assert_equal 1.5, contributions(:pending).processing_fees
      end
      should "decrease the net_amount by the #transaction_processing_fee" do
        assert_equal 0.0, contributions(:pending).net_amount
        contributions(:pending).send(:increment_processing_fees)
        assert_equal -1.5, contributions(:pending).net_amount
      end
    end
    
    should "increase the net amount by the amount" do
      assert_difference 'contributions(:pending).net_amount', 20.0 do
        contributions(:pending).send(:add_amount_to_net)
        contributions(:pending).reload
      end
    end
    
    should "decrease the net amount by the amount" do
      assert_difference 'contributions(:pending).net_amount', -20.0 do
        contributions(:pending).send(:subtract_amount_from_net)
        contributions(:pending).reload
      end
    end
    
    should "send a receipt to the contributor" do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        contributions(:approved).send(:send_receipt)
      end
      email = ActionMailer::Base.deliveries.first
      assert_equal contributions(:approved).email, email.to[0]
    end
    
    should "schedule a job to check the settlement status" do
      assert_difference 'Delayed::Job.count', +1 do
        contributions(:approved).send(:schedule_settlement_check)
      end
      job = Delayed::Job.last
      assert_equal contributions(:approved).id, job.payload_object[:contribution_id]
    end
    
    should "on #transaction_errors return a string list of errors when the current transaction failed" do
      @contribution = contributions(:approved)
      @contribution.stubs(:transaction_result).returns(multiple_gateway_error_result)
      assert_equal "(81528) The amount is too large., (91701) The billing address doesn't match., Processor Declined", @contribution.transaction_errors
    end
    
    should "on #transaction_errors return nil when a current transaction doesn't exist" do
      @contribution = contributions(:approved)
      assert_nil @contribution.transaction_errors
    end
    
    should "on #transaction_errors return nil when the current transaction was a success" do
      @contribution = contributions(:approved)
      @contribution.stubs(:transaction_result).returns(gateway_sale_result(:success))
      assert_nil @contribution.transaction_errors
    end
    
    context "on initial save" do
      setup do
        @contribution = Contribution.make
        @contribution.reload
      end
      
      should "have a state of pending" do
        assert @contribution.pending?
      end
      
      should "set the order id" do
        assert @contribution.order_id.present?
      end
      
      should "set whether it is a test transaction" do
        assert @contribution.test?
      end
      
      should "have processing fees of 0.00" do
        assert_equal 0.0, @contribution.processing_fees
      end
      
      should "have a net amount of 0.00" do
        assert_equal 0.0, @contribution.net_amount
      end
    end
    
    context "that is pending" do
      setup do
        @contribution = Contribution.make(:amount => 100.00, :compliance_confirmation => true)
        @contribution.stubs(:send_receipt).returns(true)
        @contribution.transactions.stubs(:create).returns(true)
      end
      
      should "be approvable" do
        @contribution.stubs(:process_approval).returns(true)
        assert @contribution.approve! :approved, {}
      end
      
      should "not be settleable" do
        assert_raise(AASM::InvalidTransition){ @contribution.settle! }
      end
      
      should "not be reversible" do
        assert !@contribution.reversible?
      end
      
      should "raise an error when reversed" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction is pending and cannot be reversed.") do
          @contribution.reverse
        end
      end
      
      should "not be voidable" do
        assert_raise(AASM::InvalidTransition){ @contribution.void! }
      end
      
      should "not be refundable" do
        assert_raise(AASM::InvalidTransition){ @contribution.refund! }
      end
      
      should "not be payable" do
        assert_raise(AASM::InvalidTransition){ @contribution.payout! }
      end
      
      context "when approved" do
        should "send the transaction to the gateway for approval" do
          @contribution.expects(:process_approval).once.returns(true)
          @contribution.approve! :approved, {}
        end
        
        context "and is approved by the gateway" do
          setup do
            Braintree::Transaction.expects(:sale).once.returns(gateway_sale_result(:success))
          end
          
          should "increment the processing fees" do
            @contribution.expects(:increment_processing_fees).once.returns(true)
            @contribution.approve! :approved, credit_card
          end
          
          should "change the state to approved" do
            assert !@contribution.approved?
            @contribution.approve! :approved, credit_card
            assert @contribution.approved?
          end
          
          should "schedule the system to check if the transaction is settled in 24 hours" do
            @contribution.expects(:schedule_settlement_check).once.returns(true)
            @contribution.approve! :approved, credit_card
          end
          
          should "send a receipt to the contributor" do
            @contribution.expects(:schedule_sending_receipt).once.returns(true)
            @contribution.approve! :approved, credit_card
          end
          
          should "save a masked version of the credit card number" do
            @contribution.approve! :approved, credit_card
            assert_equal "400934******1881", @contribution.card_display_number
          end
          
          should "save the compliance statement the contributor agreed to" do
            Site.any_instance.stubs(:eligibility_statement).returns("statement")
            @contribution.approve! :approved, credit_card
            assert_equal "statement", @contribution.compliance_statement
          end
          
          should "save the card type" do
            @contribution.approve! :approved, credit_card
            assert_equal "Visa", @contribution.card_type
          end
          
          should "save the card expiration month" do
            @contribution.approve! :approved, credit_card
            assert_equal 5, @contribution.card_month
          end
          
          should "save the card expiration year" do
            @contribution.approve! :approved, credit_card
            assert_equal 2012, @contribution.card_year
          end
          
          should "save the transaction id" do
            @contribution.approve! :approved, credit_card
            assert_equal "j26hdw", @contribution.transaction_id
          end
          
          should "create a record of the gateway transaction result" do
            @contribution.transactions.expects(:create).with(
              :action => 'approve',
              :amount => 100.00,
              :success => true,
              :reference => "j26hdw"
            ).once.returns(true)
            @contribution.approve! :approved, credit_card
          end
        end
        
        context "and is rejected by the gateway" do
          setup do
            Braintree::Transaction.expects(:sale).once.returns(gateway_sale_result(:error))
          end
          
          should "set the processing fees to $0.30" do
            assert_difference "@contribution.processing_fees", BigDecimal("0.30") do
              @contribution.approve! :approved, credit_card
            end
          end
          
          should "set the net amount to -$0.30" do
            assert_difference "@contribution.net_amount", BigDecimal("-0.30") do
              @contribution.approve! :approved, credit_card
            end
          end

          should "change the state to declined" do
            assert !@contribution.declined?
            @contribution.approve! :approved, credit_card
            assert @contribution.declined?
          end
          
          should "not schedule the system to check if the transaction is settled in 24 hours" do
            assert_no_difference 'Delayed::Job.count' do
              @contribution.approve! :approved, credit_card
            end
          end
          
          should "create a record of the gateway transaction result" do
            @contribution.transactions.expects(:create).with(
              :action => 'approve',
              :amount => 100.00,
              :success => false,
              :message => "(81528) The amount is too large."
            ).once.returns(true)
            @contribution.approve! :approved, credit_card
          end
          
          should "know why it was rejected" do
            @contribution.approve! :approved, credit_card
            assert_equal "(81528) The amount is too large.", @contribution.transaction_errors
          end
        end
      end
    end
    
    context "that is approved" do
      setup do
        @contribution = Contribution.make(:status => 'approved', :amount => 100.00, :transaction_id => "j26hdw")
        Braintree::Transaction.any_instance.stubs(:void).returns(gateway_void_result(:success))
        Braintree::Transaction.stubs(:find).returns(gateway_sale_result(:success).transaction)
      end
      
      should "not be approvable" do
        assert_raise(AASM::InvalidTransition){ @contribution.approve! }
      end
      
      should "not be payable" do
        assert_raise(AASM::InvalidTransition){ @contribution.payout! }
      end
      
      should "raise an error when attempting to #reverse and the remote status is incompatible with reversal" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction's status is currently \"settlement failed\" and cannot be reversed.") do
          @contribution.expects(:remote_status).at_least_once.returns('settlement_failed')
          @contribution.reverse
        end
      end
      
      context "and hasn't been settled remotely" do
        setup do
          @contribution.stubs(:remote_status).returns('submitted_for_settlement')
        end
        
        context "when settled" do
          should "not change the net amount" do
            assert_no_difference '@contribution.net_amount' do
              @contribution.settle!
              @contribution.reload
            end
          end
          
          should "not change the state to settled" do
            @contribution.settle!
            assert_equal "approved", @contribution.status
          end
        end
        
        should "be reversible" do
          assert @contribution.reversible?
        end
        
        should "be voidable" do
          assert @contribution.void!
        end
        
        should "not be refundable" do
          assert_raise(AASM::InvalidTransition){ @contribution.refund! }
        end
        
        context "when reversed (voided)" do
          context "and is approved by the gateway" do
            should "increment the processing fees" do
              @contribution.expects(:increment_processing_fees).once.returns(true)
              @contribution.reverse
            end
            
            should "change the state to voided" do
              assert !@contribution.voided?
              @contribution.reverse
              assert @contribution.voided?
            end
            
            should "create a record of the gateway transaction result" do
              @contribution.transactions.expects(:create).with(
                :action => 'void',
                :amount => 100.00,
                :success => true,
                :reference => "j26hdw"
              ).once.returns(true)
              @contribution.reverse
            end
            
            should_eventually "send a reversal receipt to the contributor"
          end

          context "and is rejected by the gateway" do
            setup do
              Braintree::Transaction.any_instance.stubs(:void).returns(gateway_void_result(:error))
            end

            should "increment the processing fees" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                @contribution.expects(:increment_processing_fees).once.returns(true)
                @contribution.reverse
              end
            end
            
            should "not change the state and leave it as approved" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                assert @contribution.approved?
                @contribution.reverse
                assert @contribution.approved?
              end
            end
            
            should "create a record of the gateway transaction result" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                @contribution.transactions.expects(:create).with(
                  :action => 'void',
                  :amount => 100.00,
                  :success => false,
                  :message => "(91504) Cannot be voided."
                ).once.returns(true)
                @contribution.reverse
              end
            end
            
            should "raise a TransactionRejectedError with the gateway message and know why it was rejected" do
              assert_raise(Stumpwise::Transaction::RejectedError, "(91504) Cannot be voided.") do
                @contribution.reverse
                assert_equal "(91504) Cannot be voided.", @contribution.transaction_errors
              end
            end
            
            should_eventually "not send a reversal receipt"
          end
        end
      end
      
      context "and has already been settled remotely" do
        setup do
          @contribution.stubs(:remote_status).returns('settled')
        end
        
        context "when settled" do
          should "increase the net amount by the contribution amount" do
            assert_difference '@contribution.net_amount', +100.0 do
              @contribution.settle!
              @contribution.reload
            end
          end
          
          should "change the state to settled" do
            @contribution.settle!
            assert_equal "settled", @contribution.status
          end
        end
        
        should "be reversible" do
          assert @contribution.reversible?
        end
        
        should "not be voidable" do
          assert_equal false, @contribution.void!
        end
        
        # We have to mark it as settled first
        should "not be refundable" do
          assert_raise(AASM::InvalidTransition){ @contribution.refund! }
        end
        
        context "when reversed (refunded)" do
          context "and is approved by the gateway" do
            setup do
              Braintree::Transaction.any_instance.stubs(:refund).returns(gateway_refund_result(:success))
              Braintree::Transaction.stubs(:find).returns(gateway_sale_result(:success).transaction)
            end
            
            should "settle the transaction first" do
              @contribution.expects(:settle!).once
              @contribution.reverse
            end
            
            should "change the state to refunded" do
              assert !@contribution.refunded?
              @contribution.reverse
              assert @contribution.refunded?
            end
            
            should "increment the processing fees" do
              @contribution.expects(:increment_processing_fees).once.returns(true)
              @contribution.reverse
            end
            
            should "reduce the net amount by the amount" do
              @contribution.expects(:subtract_amount_from_net).once.returns(true)
              @contribution.reverse
            end
            
            should "save the refund transaction id" do
              @contribution.reverse
              assert_equal "gxgpyb", @contribution.refund_transaction_id
            end
            
            should "create a record of the gateway transaction result" do
              @contribution.transactions.expects(:create).with(
                :action => 'refund',
                :amount => 100.00,
                :success => true,
                :reference => "gxgpyb"
              ).once.returns(true)
              @contribution.reverse
            end

            should_eventually "send a reversal receipt to the contributor"
          end
          
          context "and is rejected by the gateway" do
            setup do
              Braintree::Transaction.any_instance.stubs(:refund).returns(gateway_refund_result(:error))
              Braintree::Transaction.stubs(:find).returns(gateway_sale_result(:success).transaction)
            end

            should "change the state to settled" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                assert !@contribution.settled?
                @contribution.reverse
                assert @contribution.settled?
              end
            end
            
            should "increment the processing fees" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                @contribution.expects(:increment_processing_fees).once.returns(true)
                @contribution.reverse
              end
            end
            
            should "not reduce the net amount by the amount" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                @contribution.expects(:subtract_amount_from_net).never
                @contribution.reverse
              end
            end

            should "not save the refund transaction id" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                @contribution.reverse
                assert_nil @contribution.refund_transaction_id
              end
            end
            
            should "create a record of the gateway transaction result" do
              assert_raise(Stumpwise::Transaction::RejectedError) do
                @contribution.transactions.expects(:create).with(
                  :action => 'refund',
                  :amount => 100.00,
                  :success => false,
                  :message => "(91521) The refund amount is too large."
                ).once.returns(true)
                @contribution.reverse
              end
            end
            
            should "raise a TransactionRejectedError with the gateway message and know why it was rejected" do
              assert_raise(Stumpwise::Transaction::RejectedError, "(91521) The refund amount is too large.") do
                @contribution.reverse
                assert_equal "(91521) The refund amount is too large.", @contribution.transaction_errors
              end
            end

            should_eventually "not send a reversal receipt to the contributor"
          end
        end
      end
    end
    
    context "that is declined" do
      setup do
        @contribution = Contribution.make(:status => 'declined', :amount => 100.00)
      end
      
      should "not be approvable" do
        assert_raise(AASM::InvalidTransition){ @contribution.approve! }
      end
      
      should "not be settleable" do
        assert_raise(AASM::InvalidTransition){ @contribution.settle! }
      end
      
      should "not be reversible" do
        assert !@contribution.reversible?
      end
      
      should "raise an error when reversed" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction is declined and cannot be reversed.") do
          @contribution.reverse
        end
      end
      
      should "not be voidable" do
        assert_raise(AASM::InvalidTransition){ @contribution.void! }
      end
      
      should "not be refundable" do
        assert_raise(AASM::InvalidTransition){ @contribution.refund! }
      end
      
      should "not be payable" do
        assert_raise(AASM::InvalidTransition){ @contribution.payout! }
      end
    end

    context "that is voided" do
      setup do
        @contribution = Contribution.make(:status => 'voided', :amount => 100.00, :transaction_id => "j26hdw")
      end
      
      should "not be approvable" do
        assert_raise(AASM::InvalidTransition){ @contribution.approve! }
      end
      
      should "not be settleable" do
        assert_raise(AASM::InvalidTransition){ @contribution.settle! }
      end
      
      should "not be reversible" do
        assert !@contribution.reversible?
      end
      
      should "raise an error when reversed" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction is voided and cannot be reversed.") do
          @contribution.reverse
        end
      end
      
      should "not be voidable" do
        assert_raise(AASM::InvalidTransition){ @contribution.void! }
      end
      
      should "not be refundable" do
        assert_raise(AASM::InvalidTransition){ @contribution.refund! }
      end
      
      should "not be payable" do
        assert_raise(AASM::InvalidTransition){ @contribution.payout! }
      end
    end
    
    context "that is settled" do
      setup do
        @contribution = Contribution.make(:status => 'settled', :amount => 100.00, :transaction_id => "j26hdw")
        @contribution.stubs(:remote_status).returns('settled')
      end
      
      should "not be approvable" do
        assert_raise(AASM::InvalidTransition){ @contribution.approve! }
      end
      
      should "not be settleable" do
        assert_raise(AASM::InvalidTransition){ @contribution.settle! }
      end
      
      should "be reversible" do
        assert @contribution.reversible?
      end
      
      should "raise an error when attempting to #reverse and the remote status is incompatible with reversal" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction's status is currently \"settlement failed\" and cannot be reversed.") do
          @contribution.expects(:remote_status).at_least_once.returns('settlement_failed')
          @contribution.reverse
        end
      end
      
      should "not be voidable" do
        assert_raise(AASM::InvalidTransition){ @contribution.void! }
      end

      should "be refundable" do
        Braintree::Transaction.any_instance.stubs(:refund).returns(gateway_refund_result(:success))
        Braintree::Transaction.stubs(:find).returns(gateway_sale_result(:success).transaction)
        assert @contribution.refund!
      end
      
      context "when reversed (refunded)" do
        context "and is approved by the gateway" do
          setup do
            Braintree::Transaction.any_instance.stubs(:refund).returns(gateway_refund_result(:success))
            Braintree::Transaction.stubs(:find).returns(gateway_sale_result(:success).transaction)
          end
          
          should "change the state to refunded" do
            assert !@contribution.refunded?
            @contribution.reverse
            assert @contribution.refunded?
          end
          
          should "increment the processing fees" do
            @contribution.expects(:increment_processing_fees).once.returns(true)
            @contribution.reverse
          end
          
          should "reduce the net amount by the amount" do
            @contribution.expects(:subtract_amount_from_net).once.returns(true)
            @contribution.reverse
          end
          
          should "save the refund transaction id" do
            @contribution.reverse
            assert_equal "gxgpyb", @contribution.refund_transaction_id
          end
          
          should "create a record of the gateway transaction result" do
            @contribution.transactions.expects(:create).with(
              :action => 'refund',
              :amount => 100.00,
              :success => true,
              :reference => "gxgpyb"
            ).once.returns(true)
            @contribution.reverse
          end

          should_eventually "send a reversal receipt to the contributor"
        end
        
        context "and is rejected by the gateway" do
          setup do
            Braintree::Transaction.any_instance.stubs(:refund).returns(gateway_refund_result(:error))
            Braintree::Transaction.stubs(:find).returns(gateway_sale_result(:success).transaction)
          end

          should "not change the state" do
            assert_raise(Stumpwise::Transaction::RejectedError) do
              assert @contribution.settled?
              @contribution.reverse
              assert @contribution.settled?
            end
          end
          
          should "increment the processing fees" do
            assert_raise(Stumpwise::Transaction::RejectedError) do
              @contribution.expects(:increment_processing_fees).once.returns(true)
              @contribution.reverse
            end
          end
          
          should "not reduce the net amount by the amount" do
            assert_raise(Stumpwise::Transaction::RejectedError) do
              @contribution.expects(:subtract_amount_from_net).never
              @contribution.reverse
            end
          end

          should "not save the refund transaction id" do
            assert_raise(Stumpwise::Transaction::RejectedError) do
              @contribution.reverse
              assert_nil @contribution.refund_transaction_id
            end
          end
          
          should "create a record of the gateway transaction result" do
            assert_raise(Stumpwise::Transaction::RejectedError) do
              @contribution.transactions.expects(:create).with(
                :action => 'refund',
                :amount => 100.00,
                :success => false,
                :message => "(91521) The refund amount is too large."
              ).once.returns(true)
              @contribution.reverse
            end
          end
          
          should "raise a TransactionRejectedError with the gateway message and know why it was rejected" do
            assert_raise(Stumpwise::Transaction::RejectedError, "(91521) The refund amount is too large.") do
              @contribution.reverse
              assert_equal "(91521) The refund amount is too large.", @contribution.transaction_errors
            end
          end

          should_eventually "not send a reversal receipt to the contributor"
        end
      end
      
      should "be payable" do
        assert @contribution.payout!
      end
      
      context "when paid out" do
        should "change the state to paid" do
          assert !@contribution.paid?
          @contribution.payout
          assert @contribution.paid?
        end
      end
    end
    
    context "that is refunded" do
      setup do
        @contribution = Contribution.make(:status => 'refunded', :amount => 100.00, :transaction_id => "j26hdw")
      end
      
      should "not be approvable" do
        assert_raise(AASM::InvalidTransition){ @contribution.approve! }
      end
      
      should "not be settleable" do
        assert_raise(AASM::InvalidTransition){ @contribution.settle! }
      end
      
      should "not be reversible" do
        assert !@contribution.reversible?
      end
      
      should "raise an error when reversed" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction is refunded and cannot be reversed.") do
          @contribution.reverse
        end
      end
      
      should "not be voidable" do
        assert_raise(AASM::InvalidTransition){ @contribution.void! }
      end
      
      should "not be refundable" do
        assert_raise(AASM::InvalidTransition){ @contribution.refund! }
      end
      
      should "not be payable" do
        assert_raise(AASM::InvalidTransition){ @contribution.payout! }
      end
    end

    context "that is paid" do
      setup do
        @contribution = Contribution.make(:status => 'paid', :amount => 100.00, :transaction_id => "j26hdw")
      end
      
      should "not be approvable" do
        assert_raise(AASM::InvalidTransition){ @contribution.approve! }
      end
      
      should "not be settleable" do
        assert_raise(AASM::InvalidTransition){ @contribution.settle! }
      end
      
      should "not be reversible" do
        assert !@contribution.reversible?
      end
      
      should "raise an error when reversed" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction is paid and cannot be reversed.") do
          @contribution.reverse
        end
      end
      
      should "not be voidable" do
        assert_raise(AASM::InvalidTransition){ @contribution.void! }
      end
      
      should "not be refundable" do
        assert_raise(AASM::InvalidTransition){ @contribution.refund! }
      end
      
      should "not be payable" do
        assert_raise(AASM::InvalidTransition){ @contribution.payout! }
      end
    end
    
    context "that is legacy and settled" do
      setup do
        @contribution = contributions(:legacy)
      end
      
      should "not be approvable" do
        assert_raise(AASM::InvalidTransition){ @contribution.approve! }
      end
      
      should "not be settleable" do
        assert_raise(AASM::InvalidTransition){ @contribution.settle! }
      end
      
      should "not be reversible" do
        assert !@contribution.reversible?
      end
      
      should "raise an error when reversed" do
        assert_raise(Stumpwise::Transaction::ReversalError, "This transaction is paid and cannot be reversed.") do
          @contribution.reverse
        end
      end
      
      should "not be voidable" do
        assert_raise(AASM::InvalidTransition){ @contribution.void! }
      end
      
      context "when refunded" do
        should "not change the state from settled" do
          assert @contribution.settled?
          @contribution.refund!
          assert @contribution.settled?
        end
        
        should "not process the refund" do
          Contribution.any_instance.expects(:process_refund).never
          @contribution.refund!
        end
      end
      
      should "be payable" do
        assert @contribution.payout!
      end
      
      context "when paid out" do
        should "change the state to paid" do
          assert !@contribution.paid?
          @contribution.payout
          assert @contribution.paid?
        end
      end
    end
  end
end
