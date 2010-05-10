require 'test_helper'

class ThemeTest < ActiveSupport::TestCase
  should_have_many :sites, :liquid_templates, :layouts, :templates, :assets
  should_validate_presence_of :name  
end
