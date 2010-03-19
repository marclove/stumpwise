class BaseDrop < Liquid::Drop
  class_inheritable_reader :liquid_attributes
  write_inheritable_attribute :liquid_attributes, [:id]
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
end