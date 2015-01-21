require 'spec_helper'

describe SortingOffice::App do

  before(:each) do
    @postcode = FactoryGirl.create(:postcode, name: "EC2A 4JE", area: "EC", lat_lng: [51.522387, -0.083648])
    @town = FactoryGirl.create(:town, name: "LONDON", area: "EC")
    @street = FactoryGirl.create(:street, name: "CLIFTON STREET", lat_lng: [51.5224342908254, -0.08321407726274722])
    FactoryGirl.create(:locality, name: "STUB")
    Town.es.index_all
    Town.es.index.refresh
    Locality.es.index_all
    Locality.es.index.refresh
  end

  it "should return address parts" do
    Timecop.freeze
    allow(SortingOffice::Provenance).to receive(:current_sha).and_return("195614f8187bb497c59a0caa8ee3fdfce1f1aa2f")

    post '/address', address: "3rd Floor, 65 Clifton Street, London EC2A 4JE"

    response = JSON.parse last_response.body

    expect(response["saon"]).to eq("3rd Floor")
    expect(response["paon"]).to eq("65")
    expect(response["street"]).to eq("Clifton Street")
    expect(response["town"]).to eq("London")
    expect(response["postcode"]).to eq("EC2A 4JE")
    expect(response["provenance"]).to eq({
      "activity" => {
        "executed_at" => DateTime.now.iso8601,
        "processing_scripts" => "https://github.com/OpenAddressesUK/sorting_office",
        "derived_from" => [
          {
            "type" => "userInput",
            "input" => "3rd Floor, 65 Clifton Street, London EC2A 4JE",
            "inputted_at" => DateTime.now.iso8601,
            "processing_script" => "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/sorting_office/address.rb"
          },
          {
            "type" => "Source",
            "urls" => [
              "http://alpha.openaddressesuk.org/postcodes/#{@postcode.token}"
            ],
            "downloaded_at" => DateTime.now.iso8601,
            "processing_script" => "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/models/postcode.rb"
          },
          {
            "type" => "Source",
            "urls" => [
              "http://alpha.openaddressesuk.org/towns/#{@town.token}"
            ],
            "downloaded_at" => DateTime.now.iso8601,
            "processing_script" => "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/models/town.rb"
          },
          {
            "type" => "Source",
            "urls" => [
              "http://alpha.openaddressesuk.org/streets/#{@street.token}"
            ],
            "downloaded_at" => DateTime.now.iso8601,
            "processing_script" => "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/models/street.rb"
          }
        ]
      }
      })
    Timecop.return
  end

  it "returns an error if there is no postcode provided" do
    post '/address', address: "3rd Floor, 65 Clifton Street, London"

    expect(last_response.status).to eq(400)
    response = JSON.parse last_response.body
    expect(response["error"]).to eq("We couldn't detect a postcode in your address. Please resubmit with a valid postcode.")
  end

  it "does not return provenance if noprov is set" do
    post '/address', address: "3rd Floor, 65 Clifton Street, London EC2A 4JE", noprov: true

    response = JSON.parse last_response.body
    
    expect(response["provenance"]).to eq(nil)
  end

end
