$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'sorting_office'
require 'colorize'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--exclude-pattern "spec/big_old_list_spec.rb"'
end

task :bootstrap do
  # Download and extract database dump
  puts "Downloading the database dump...".green
  `wget https://s3-eu-west-1.amazonaws.com/download.openaddressesuk.org/sorting_office/dump.tar.gz 2>&1`
  puts "Extracting the files...".green
  `tar -zxvf dump.tar.gz 2>&1`
  # Mongo import the extract
  puts "Importing the data...".green
  `mongorestore --db distiller ./dump/distiller 2>&1`
  # Run the indexes
  puts "Running the indexes...".green
  Locality.es.index_all
  Town.es.index_all
  # Clean up
  puts "Cleaning up...".green
  `rm dump.tar.gz 2>&1`
  `rm -rf ./dump 2>&1`
  puts "Done!".green
end

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

task :default => :spec
