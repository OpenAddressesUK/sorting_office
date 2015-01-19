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

  it "only removes the last instance of the town name after parsing" do
    FactoryGirl.create(:street, name: "LONDON ROAD", lat_lng: [51.5224342908254, -0.08321407726274722])
    address = SortingOffice::Address.new("123 London Road, London EC2A 4JE")
    address.get_postcode
    address.get_town

    expect(address.address).to eq("123 London Road,  ")
  end

  it "removes the street after parsing" do
    FactoryGirl.create(:street, name: "PRINCE'S ROAD", lat_lng: [51.5224342908254, -0.08321407726274722])
    address = SortingOffice::Address.new("123 Princes Road, London EC2A 4JE")
    address.get_postcode
    address.get_street

    expect(address.address).to_not match /Princes Road/
  end

  it "ignores special characters when removing a street" do

  end

  it "gets the paon and saon" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London EC2A 4JE")
    address.get_postcode
    address.get_town
    address.get_street
    address.get_aon

    expect(address.paon).to eq("65")
    expect(address.saon).to eq("3rd Floor")
  end

  it "gets the paon and saon if there is no comma" do
    address = SortingOffice::Address.new("3rd Floor 65 Clifton Street, London EC2A 4JE")
    address.get_postcode
    address.get_town
    address.get_street
    address.get_aon

    expect(address.paon).to eq("65")
    expect(address.saon).to eq("3rd Floor")
  end

  it "gets the paon if no saon is present" do
    FactoryGirl.create(:street, name: "WALDEMAR AVENUE", lat_lng: [51.5224342908254, -0.08321407726274722])
    address = SortingOffice::Address.new("26 Waldemar Avenue Mansions, Waldemar Avenue, London, EC2A 4JE")
    address.get_postcode
    address.get_town
    address.get_street
    address.get_aon

    expect(address.paon).to eq("26 Waldemar Avenue Mansions")
  end

end
