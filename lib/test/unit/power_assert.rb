require 'test/unit/power_assert/version'

require 'test/unit'
require 'power_assert'

module Test::Unit
  module PowerAssert
    module Assertions
      def power_assert(&blk)
        ::PowerAssert.start(blk, assertion_method: __method__) do |pa|
          class << pa.message_proc
            alias to_s call
          end
          assert_block(pa.message_proc) do
            pa.yield
          end
        end
      end
    end
  end

  class TestCase
    include PowerAssert::Assertions
  end
end
