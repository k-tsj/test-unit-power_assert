require 'test/unit'
require 'test/unit/power_assert'

class TestPowerAssert < Test::Unit::TestCase
  def test_successful
    assert do
      true
    end
    assert(true)
    power_assert do
      true
    end
  end

  def test_assert_failed
    return unless ENV['DEMO']
    assert do
      "0".class == "3".to_i.times.map {|i| i + 1 }.class
    end
  end

  def test_power_assert_failed
    return unless ENV['DEMO']
    power_assert do
      "0".class == "3".to_i.times.map {|i| i + 1 }.class
    end
  end
end
