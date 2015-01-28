require 'bundler'
Bundler.require(:default)

Dotenv.load

require 'mongoid_address_models/require_all'

if ENV["BONSAI_URL"]
  Mongoid::Elasticsearch.client_options = { url: ENV["BONSAI_URL"] }
end

Mongoid.load!(File.join(File.dirname(__FILE__), "..", "config", "mongoid.yml"), ENV["MONGOID_ENVIRONMENT"] || :development)

require 'sorting_office/models/street'
require 'sorting_office/models/locality'
require 'sorting_office/models/town'
require 'sorting_office/models/postcode'

require 'sorting_office/provenance'
require 'sorting_office/address'
require 'sorting_office/queue'

module SortingOffice
end
