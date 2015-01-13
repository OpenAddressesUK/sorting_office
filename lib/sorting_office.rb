require 'bundler'
Bundler.require(:default)

require 'mongoid_address_models/require_all'

Mongoid.load!(File.join(File.dirname(__FILE__), "..", "config", "mongoid.yml"), ENV["MONGOID_ENVIRONMENT"] || :development)

require 'sorting_office/address'
require 'sorting_office/street'
require 'sorting_office/locality'
require 'sorting_office/town'
require 'sorting_office/postcode'

module SortingOffice
end
