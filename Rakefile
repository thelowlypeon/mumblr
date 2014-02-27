require 'rake/testtask'

task :console do
  require 'irb'
  require 'irb/completion'
  require 'mumblr'
  ARGV.clear
  IRB.start
end

task :buildgem do
  exec('gem build mumblr.gemspec && gem install ./mumblr-0.0.0.gem')
end

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test
