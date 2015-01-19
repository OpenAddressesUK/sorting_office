require 'bundler'
Bundler.require(:default)

require 'mongoid-elasticsearch'
Mongoid::Elasticsearch.prefix = ENV["MONGOID_ENVIRONMENT"] || ""

require 'mongoid_address_models/require_all'

Mongoid.load!(File.join(File.dirname(__FILE__), "..", "config", "mongoid.yml"), ENV["MONGOID_ENVIRONMENT"] || :development)

require 'sorting_office/models/street'
require 'sorting_office/models/locality'
require 'sorting_office/models/town'
require 'sorting_office/models/postcode'

require 'sorting_office/address'

module SortingOffice
end
