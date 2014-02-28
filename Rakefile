require 'rake/testtask'

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

task :buildgem do
  exec("gem build mumblr.gemspec && gem install mumblr")
end

desc "Run tests"
task :default => :test
