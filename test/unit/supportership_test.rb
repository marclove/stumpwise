require 'test_helper'

class SupportershipTest < ActiveSupport::TestCase
  should_belong_to :supporter, :site
  should_validate_presence_of :supporter_id, :site_id
end
