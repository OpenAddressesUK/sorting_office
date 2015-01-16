require 'spec_helper'

describe SortingOffice::Address do

  before(:each) do
    FactoryGirl.create(:postcode, name: "EC2A 4JE", area: "EC", lat_lng: [51.522387, -0.083648])
    FactoryGirl.create(:town, name: "LONDON", area: "EC")
    FactoryGirl.create(:street, name: "CLIFTON STREET", lat_lng: [51.5224342908254, -0.08321407726274722])
    Town.es.index_all
    Town.es.index.refresh
  end

  it "removes the postcode after parsing" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London EC2A 4JE")
    address.get_postcode

    expect(address.address).to_not match /EC2A 4JE/
  end

  it "removes the town after parsing" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London EC2A 4JE")
    address.get_postcode
    address.get_town

    expect(address.address).to_not match /London/
  end

  it "removes the street after parsing" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London EC2A 4JE")
    address.get_postcode
    address.get_street

    expect(address.address).to_not match /Clifton Street/
  end

end
