$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'sinatra'
require 'sorting_office'
require 'json'

module SortingOffice
  class App < Sinatra::Base

    before do
      response.headers['Access-Control-Allow-Origin'] = "*"
    end

    get '/' do
      send_file 'public/index.html'
    end

    post '/address' do
      content_type :json

      if params[:address]
        address = SortingOffice::Address.new(params[:address])
        address.parse

        if address.postcode.nil?
          status 400
          {
            error: "We couldn't detect a real postcode in your address. Please resubmit with a valid postcode."
          }.to_json
        else
          h = {
            saon: address.saon,
            paon: address.paon,
            street: address.street.try(:name).try(:titleize),
            locality: address.locality.try(:name),
            town: address.town.try(:name).try(:titleize),
            postcode: address.postcode.try(:name),
            provenance: address.provenance
          }
          SortingOffice::Queue.perform(h) if params[:contribute]
          h = h.tap do |h|
            [:street, :locality, :town, :postcode].each do |part|
              h[part] = add_url(address.send(part))
            end
            h.delete(:provenance) if params[:noprov]
          end
          h.to_json
        end
      end
    end

    def add_url(part)
      if part.nil?
        nil
      else
       {
         name: part.class == Postcode ? part.name : part.name.titleize,
         url: "http://alpha.openaddressesuk.org/#{part.class.to_s.downcase.pluralize}/#{part.token}"
       }
     end
    end

  end
end
