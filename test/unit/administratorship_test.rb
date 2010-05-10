require 'test_helper'

class AdministratorshipTest < ActiveSupport::TestCase
  context "An administratorship" do
    should_belong_to :administrator, :site
    should_validate_presence_of :administrator_id, :site_id
  end  
end
