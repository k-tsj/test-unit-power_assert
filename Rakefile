require "rake/testtask"
task :default => :test
Rake::TestTask.new do |t|
  t.test_files = FileList["test/helper.rb", "test/test_*.rb"]
end
