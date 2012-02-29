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

class BaseDrop < Liquid::Drop
  class_inheritable_reader :liquid_attributes
  write_inheritable_attribute :liquid_attributes, []
  attr_reader :source
  delegate :hash, :to => :source
  
  def initialize(source)
    @source = source
    # Create a hash of the declared liquid_attributes, used later by before_method
    @liquid = liquid_attributes.inject({}){|h,k| h.update k.to_s => @source.send(k)}
  end
  
  def before_method(method)
    @liquid[method.to_s]
  end
  
  def eql?(comparison_object)
    self == (comparison_object)
  end

  def ==(comparison_object)
    self.source == (comparison_object.is_a?(self.class) ? comparison_object.source : comparison_object)
  end
end