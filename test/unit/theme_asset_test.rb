require 'test_helper'

class ThemeAssetTest < ActiveSupport::TestCase
  should_belong_to :theme
  should_validate_presence_of :theme_id
end
