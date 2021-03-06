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

class SmsCampaignTest < ActiveSupport::TestCase
  context "An SMS Campaign" do
    setup do
      Thread.current['user'] = users(:authorized)
    end
    
    should_belong_to :site
    should_belong_to :creator
    should_have_many :sms_messages
    should_have_many :recipients, :through => :sms_messages
  
    should_ensure_length_in_range :message, 1..160
    should_allow_values_for :recipients_count
  
    should "set the creator to the current user on create" do
      @campaign = SmsCampaign.make
      assert_equal @campaign.creator, users(:authorized)
    end
    
    should "set created_at on create" do
      @campaign = SmsCampaign.make
      assert @campaign.created_at.present?
    end
    
    should "set the status to draft on create" do
      @campaign = SmsCampaign.make
      assert @campaign.draft?
    end
    
    context "campaign sent" do
      setup do
        @campaign = sites(:with_supporters).sms_campaigns.create(:message => "works")
      end
      
      should "know how much it costs" do
        assert_equal 0.10, @campaign.cost
      end
      
      context "and site doesn't have a valid payment method" do
        setup do
          Site.any_instance.stubs(:valid_payment_method_on_file?).returns(false)
        end
        
        should "not change the status" do
          assert @campaign.draft?
          @campaign.send_campaign
          assert @campaign.draft?
        end
        
        should "not create any sms messages" do
          Twilio::Sms.expects(:message).never
          assert_no_difference 'SmsMessage.count' do
            @campaign.send_campaign
          end
        end
      end

      context "and site has a valid payment method" do
        setup do
          Site.any_instance.stubs(:valid_payment_method_on_file?).returns(true)
        end
        
        context "and payment authorization is rejected" do
        end
        
        context "and payment is authorized" do
          context "and payment settlement fails" do
          end
          
          context "and payment is settled" do
            setup do
              Twilio::Sms.expects(:message).times(2).returns(true)
            end
            
            should "change the status to sent" do
              assert @campaign.draft?
              @campaign.send_campaign
              assert @campaign.sent?
            end
            
            should "create sms messages when sent" do
              assert_difference 'SmsMessage.count', 2 do
                @campaign.send_campaign
              end
            end
            
            should "increment the recipients count when sent" do
              assert_difference '@campaign.recipients_count', 2 do
                @campaign.send_campaign
                @campaign.reload
              end
            end
            
            should "know what the cost was (not modified by the addition of supporters after being sent)" do
              assert_no_difference '@campaign.cost' do
                @campaign.send_campaign
                Supportership.create!(:site => @campaign.site, :supporter => supporters(:other_site_supporter), :receive_sms => true)
              end
            end
          end
        end
      end
    end
  end
end
