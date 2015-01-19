require 'spec_helper'

describe SortingOffice::App do

  before(:each) do
    FactoryGirl.create(:postcode, name: "EC2A 4JE", area: "EC", lat_lng: [51.522387, -0.083648])
    FactoryGirl.create(:town, name: "LONDON", area: "EC")
    FactoryGirl.create(:street, name: "CLIFTON STREET", lat_lng: [51.5224342908254, -0.08321407726274722])
    FactoryGirl.create(:locality, name: "STUB")
    Town.es.index_all
    Town.es.index.refresh
    Locality.es.index_all
    Locality.es.index.refresh
  end

  it "should return address parts" do
    post '/address', address: "3rd Floor, 65 Clifton Street, London EC2A 4JE"

    response = JSON.parse last_response.body

    expect(response["saon"]).to eq("3rd Floor")
    expect(response["paon"]).to eq("65")
    expect(response["street"]).to eq("CLIFTON STREET")
    expect(response["town"]).to eq("LONDON")
    expect(response["postcode"]).to eq("EC2A 4JE")
  end

end
