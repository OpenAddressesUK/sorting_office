$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'sorting_office'
require 'colorize'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--exclude-pattern "spec/big_old_list_spec.rb"'
end

task :default => :spec

namespace :es do
  task :index do
    print "Indexing localities...".yellow
    Locality.es.index.create
    Locality.es.index_all
    print " Done!\n".green
    print "Indexing towns...".yellow
    Town.es.index.create
    Town.es.index_all
    print " Done!\n".green
  end
end
