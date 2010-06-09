module Stumpwise
  class ParentItemDestroyError < RuntimeError; end
  
  module Transaction
    class ReversalError < RuntimeError; end
    class RejectedError < RuntimeError; end
    class NotSettledError < RuntimeError; end
  end
end