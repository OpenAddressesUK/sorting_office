$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--exclude-pattern "spec/big_old_list_spec.rb"'
end

task :default => :spec
