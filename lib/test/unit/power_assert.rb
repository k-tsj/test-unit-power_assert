# power_assert.rb
#
# Copyright (C) 2014-2016 Kazuki Tsujimoto, All rights reserved.

require 'test/unit/power_assert/version'

require 'test/unit'
require 'power_assert'

begin
  if Gem.loaded_specs['test-unit'].version >= Gem::Version.new('3')
    warn "test-unit-power_assert: warning: You don't need to require test-unit-power_assert."
    warn "test-unit-power_assert: warning: test-unit 3 or later has built-in support for power_assert."
  end
rescue
end

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
