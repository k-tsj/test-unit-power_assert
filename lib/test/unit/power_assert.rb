# power_assert.rb
#
# Copyright (C) 2014 Kazuki Tsujimoto, All rights reserved.

require 'test/unit/power_assert/version'

require 'test/unit'
require 'power_assert'

module Test::Unit::Assertions
  alias __assert_orig__ assert

  def assert(boolean = nil, message = nil, &blk)
    if blk
      ::PowerAssert.start(blk, assertion_method: __callee__) do |pa|
        prc = pa.message_proc
        class << prc
          alias to_s call
        end
        assert_block(prc) do
          pa.yield
        end
      end
    else
      __assert_orig__(boolean, message)
    end
  end

  alias power_assert assert
end
