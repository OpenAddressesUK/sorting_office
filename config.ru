require 'rubygems'

ENV['RACK_ENV'] ||= 'development'

if ENV["RACK_ENV"] == "production"
  require 'rack/ssl'
  use Rack::SSL
end

require File.join(File.dirname(__FILE__), 'sorting_office.rb')

run SortingOffice::App
