$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'sinatra'
require 'sorting_office'
require 'json'

module SortingOffice
  class App < Sinatra::Base

    post '/address' do
      content_type :json

      if params[:address]
        address = SortingOffice::Address.new(params[:address])
        address.parse

        {
          saon: address.saon,
          paon: address.paon,
          street: address.street.try(:name).try(:titleize),
          locality: address.locality.try(:name),
          town: address.town.try(:name).try(:titleize),
          postcode: address.postcode.try(:name)
        }.to_json
      end
    end

  end
end
