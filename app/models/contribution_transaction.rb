# == Schema Information
# Schema version: 20100612013511
#
# Table name: contribution_transactions
#
#  id              :integer(4)      not null, primary key
#  contribution_id :integer(4)
#  amount          :integer(4)
#  success         :boolean(1)
#  reference       :string(255)
#  message         :string(255)
#  action          :string(255)
#  params          :text
#  test            :boolean(1)
#  created_at      :datetime
#  updated_at      :datetime
#

class ContributionTransaction < ActiveRecord::Base
  belongs_to :contribution
  serialize :params
 
  class << self
    def approve(amount, credit_card, options = {})
      process('approve', amount) do |gw|
        gw.purchase(amount, credit_card, options)
      end
    end
    
    def refund(amount, authorization, options = {})
      process('refund', amount) do |gw|
        gw.credit(amount, authorization, options)
      end
    end
    
    private
      def process(action, amount = nil)
      end
  end
end
