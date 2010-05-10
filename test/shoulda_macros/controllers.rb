class Test::Unit::TestCase
  def self.should_render_with(layout, template)
    should_respond_with :success
    should_render_with_layout layout
    should_render_template template
  end
  
  def self.should_paginate(name)
    should_assign_to name
    should "paginate the collection #{name}" do
      assert_respond_to assigns(name), :current_page
      assert_respond_to assigns(name), :per_page
      assert_respond_to assigns(name), :total_entries
      assert_respond_to assigns(name), :total_pages
    end
  end
end