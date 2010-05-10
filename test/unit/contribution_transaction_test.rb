require 'test_helper'

class ContributionTransactionTest < ActiveSupport::TestCase
  should_belong_to :contribution
  should_have_class_methods :approve, :refund
end
