require 'rake/testtask'
#gem build mumblr.gemspec && gem.install ./mumblr-VERSION.gem

task :console do
  require 'irb'
  require 'irb/completion'
  require 'mumblr'
  ARGV.clear
  IRB.start
end

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test
