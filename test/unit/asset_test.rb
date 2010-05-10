require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  context "An asset" do
    should_belong_to :site
    should_validate_presence_of :site_id
  end
end
