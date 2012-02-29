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

class FugueIconsHelperTest < ActionView::TestCase
  context "Fugue Icon image tag generator" do
    should "return an image tag for the given icon name" do
      assert_equal %(<img class="fugue-icon" src="/images/icons-shadowless/mail.png" />), icon_tag("mail")
    end

    should "return an image tag for icons with shadows" do
      assert_equal %(<img class="fugue-icon" src="/images/icons/mail.png" />), icon_tag("mail", :shadow => true)
    end
    
    should "return an image tag for icons with an overlay" do
      assert_equal %(<img class="fugue-icon" src="/images/icons-shadowless/_overlay/mail--pencil.png" />), icon_tag("mail", :overlay => "pencil")
    end
    
    should "accept additional class definitions for the tag" do
      assert_equal %(<img class="fugue-icon other classes" src="/images/icons-shadowless/mail.png" />), icon_tag("mail", :class => "other classes")
    end

    should "accept other arbitrary attributes for the tag" do
      assert_equal %(<img class="fugue-icon" id="my_id" src="/images/icons-shadowless/mail.png" />), icon_tag("mail", :id => "my_id")
    end
  end
end