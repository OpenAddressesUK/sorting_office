$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'sinatra'
require 'sorting_office'
require 'json'

module SortingOffice
  class App < Sinatra::Base

    get '/' do
      send_file 'lib/sorting_office/views/index.html'
    end

    post '/address' do
      content_type :json

      if params[:address]
        address = SortingOffice::Address.new(params[:address])
        address.parse

        if address.postcode.nil?
          status 400
          {
            error: "We couldn't detect a postcode in your address. Please resubmit with a valid postcode."
          }.to_json
        else
          provenance = params[:noprov] ? nil : address.provenance
          {
            saon: address.saon,
            paon: address.paon,
            street: address.street.try(:name).try(:titleize),
            locality: address.locality.try(:name),
            town: address.town.try(:name).try(:titleize),
            postcode: address.postcode.try(:name),
            provenance: provenance
          }.tap { |h| h.delete(:provenance) if provenance.nil? }.to_json
        end
      end
    end

  end
end
