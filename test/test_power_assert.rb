require 'test/unit'
require 'test/unit/power_assert'
require 'ripper'

$for_same_name = 0

class Fixnum
  def m(*)
    $for_same_name += 1
  end
end

class TestPowerAssert < Test::Unit::TestCase
  def test_failed
    power_assert do
      "0".class == "3".to_i.times.map {|i| i + 1 }.class
    end
  end

  def m(*)
    $for_same_name += 1
  end

  def test_same_name
    power_assert do
      0 == m(m.m(m { m })).m
    end
  end

  EXTRACT_METHODS_TEST = [
    [[["a", [1, 8]], ["foo", [1, 4]], ["foo", [1, 0]]],
      'foo(foo(a))'],

    [[["class", [1, 4]], ["==", [nil, nil]], ["to_i", [1, 17]], ["times", [1, 22]], ["map", [1, 28]], ["class", [1, 48]]],
      '"0".class == "3".to_i.times.map {|i| i.ccc(1) }.class'],

    [[["a", [1, 0]], ["b", [1, 2]], ["d", [1, 6]], ["c", [1, 4]]],
      'a.b.c(d)'],

    [[["b", [1, 2]], ["a", [1, 0]], ["c", [1, 5]], ["e", [1, 9]], ["d", [1, 7]]],
      'a(b).c.d(e)'],

    [[["b", [1, 4]], ["a", [1, 2]], ["c", [1, 7]], ["e", [1, 13]], ["g", [1, 11]], ["d", [1, 9]], ["f", [1, 0]]],
      'f(a(b).c.d(g(e)))']
  ]

  EXTRACT_METHODS_TEST.each_with_index do |(expect, actual), idx|
    define_method("test_extract_methods_#{idx}") do
      assert_equal expect, Test::Unit::PowerAssert.extract_methods(Ripper.sexp(actual))
    end
  end
end
