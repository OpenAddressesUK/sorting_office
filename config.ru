require 'rubygems'

ENV['RACK_ENV'] ||= 'development'

require File.join(File.dirname(__FILE__), 'sorting_office.rb')

run SortingOffice::App
