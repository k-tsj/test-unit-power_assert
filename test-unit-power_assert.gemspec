$:.push File.expand_path('../lib', __FILE__)
require 'test/unit/power_assert/version'

Gem::Specification.new do |s|
  s.name        = 'test-unit-power_assert'
  s.version     = Test::Unit::PowerAssert::VERSION
  s.authors     = ['Kazuki Tsujimoto']
  s.email       = ['kazuki@callcc.net']
  s.homepage    = 'https://github.com/k-tsj/test-unit-power_assert'
  s.summary     = %q{Power Assert for test-unit}
  s.description = %q{Power Assert for test-unit}

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f) }
  s.require_paths    = ['lib']
  s.add_runtime_dependency 'test-unit'
  s.add_runtime_dependency 'power_assert'
  s.add_development_dependency 'rake'
  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options     = ['--main', 'README.rdoc']
end
