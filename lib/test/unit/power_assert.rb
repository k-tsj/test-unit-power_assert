# power_assert.rb
#
# Copyright (C) 2014 Kazuki Tsujimoto, All rights reserved.

require 'test/unit/power_assert/version'

require 'test/unit'
require 'power_assert'

module Test::Unit
  module PowerAssert
    module Assertions
      def power_assert(&blk)
        ::PowerAssert.start(blk, assertion_method: __method__) do |pa|
          prc = pa.message_proc
          class << prc
            alias to_s call
          end
          assert_block(prc) do
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
