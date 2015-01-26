$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'coveralls'
Coveralls.wear!

ENV["MONGOID_ENVIRONMENT"] = "test"

require 'sorting_office'
require 'database_cleaner'
require 'factory_girl'
require 'rack/test'
require 'timecop'

module RSpecMixin
  include Rack::Test::Methods
  require './sorting_office'
  def app() SortingOffice::App end
end

RSpec.configure do |config|
  config.order = "random"
  config.include RSpecMixin

  FactoryGirl.definition_file_paths = ["#{Gem.loaded_specs['mongoid_address_models'].full_gem_path}/lib/mongoid_address_models/factories"]
  FactoryGirl.find_definitions

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with(:truncation)
    Town.es.index.reset
    Locality.es.index.reset
  end

  config.before(:each) do
    DatabaseCleaner.start
    Address.create_indexes
    Street.create_indexes
    Postcode.create_indexes
    Locality.create_indexes
    Town.create_indexes
    Town.es.index.reset
    Locality.es.index.reset
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Town.es.index.reset
    Locality.es.index.reset
  end
end
