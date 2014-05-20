require 'test/unit'
require 'test/unit/power_assert'

class TestPowerAssert < Test::Unit::TestCase
  def test_successful
    power_assert do
      true
    end
  end

  def test_failed
    return unless ENV['DEMO']
    power_assert do
      "0".class == "3".to_i.times.map {|i| i + 1 }.class
    end
  end
end
