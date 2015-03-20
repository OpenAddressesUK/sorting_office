require 'spec_helper'

describe SortingOffice::Address do

  before(:each) do
    FactoryGirl.create(:postcode, name: "EC2A 4JE", area: "EC", lat_lng: [-0.083648, 51.522387])
    FactoryGirl.create(:town, name: "LONDON", area: "EC")
    FactoryGirl.create(:street, name: "CLIFTON STREET", lat_lng: [-0.08321407726274722, 51.5224342908254])
    Town.es.index_all
    Town.es.index.refresh
  end

  it "removes the postcode after parsing" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London EC2A 4JE")
    address.get_postcode

    expect(address.address).to_not match /EC2A 4JE/
  end

  it "removes the postcode after if lowercase" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London ec2a 4je")
    address.get_postcode

    expect(address.address).to_not match /ec2a 4je/
  end

  it "removes the postcode after if the space is missing" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London ec2a4je")
    address.get_postcode

    expect(address.address).to_not match /ec2a4je/
  end

  it "removes the town after parsing" do
    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London EC2A 4JE")
    address.get_postcode
    address.get_town

    expect(address.address).to_not match /London/
  end

  it "only removes the last instance of the town name after parsing" do
    FactoryGirl.create(:street, name: "LONDON ROAD", lat_lng: [-0.08321407726274722, 51.5224342908254])
    address = SortingOffice::Address.new("123 London Road, London EC2A 4JE")
    address.get_postcode
    address.get_town

    expect(address.address).to eq("123 London Road,  ")
  end

  it "removes the street after parsing" do
    FactoryGirl.create(:street, name: "PRINCE'S ROAD", lat_lng: [-0.08321407726274722, 51.5224342908254])
    address = SortingOffice::Address.new("123 Princes Road, London EC2A 4JE")
    address.get_postcode
    address.get_street

    expect(address.address).to_not match /Princes Road/
  end

  it "removes the street after parsing when there is a bracket in a street name" do
    FactoryGirl.create(:street, name: "TEST STREET (WEST)", lat_lng: [-0.08321407726274722, 51.5224342908254])
    address = SortingOffice::Address.new("3rd Floor, 65 Test Street West, London EC2A 4JE")
    address.get_postcode
    address.get_town

    expect(address.address).to_not match /Clifton Street West/
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
    FactoryGirl.create(:street, name: "WALDEMAR AVENUE", lat_lng: [-0.08321407726274722, 51.5224342908254])
    address = SortingOffice::Address.new("26 Waldemar Avenue Mansions, Waldemar Avenue, London, EC2A 4JE")
    address.get_postcode
    address.get_town
    address.get_street
    address.get_aon

    expect(address.paon).to eq("26 Waldemar Avenue Mansions")
  end

  it "doesn't error if no postcode is present" do
    address = SortingOffice::Address.new("3rd Floor 65 Clifton Street, London")
    address.parse

    expect(address.postcode).to eq(nil)
  end

  it "returns the correct provenance" do
    Timecop.freeze
    allow(SortingOffice::Provenance).to receive(:current_sha).and_return("195614f8187bb497c59a0caa8ee3fdfce1f1aa2f")

    address = SortingOffice::Address.new("3rd Floor, 65 Clifton Street, London EC2A 4JE")
    address.parse

    expected = {
      activity: {
        executed_at: DateTime.now.iso8601,
        processing_scripts: "https://github.com/OpenAddressesUK/sorting_office",
        derived_from: [
          {
            type: "userInput",
            input: "3rd Floor, 65 Clifton Street, London EC2A 4JE",
            inputted_at: DateTime.now.iso8601,
            processing_script: "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/sorting_office/address.rb"
          },
          {
            type: "Source",
            urls: [
              "http://alpha.openaddressesuk.org/postcodes/#{address.postcode.token}"
            ],
            downloaded_at: DateTime.now.iso8601,
            processing_script: "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/models/postcode.rb"
          },
          {
            type: "Source",
            urls: [
              "http://alpha.openaddressesuk.org/towns/#{address.town.token}"
            ],
            downloaded_at: DateTime.now.iso8601,
            processing_script: "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/models/town.rb"
          },
          {
            type: "Source",
            urls: [
              "http://alpha.openaddressesuk.org/streets/#{address.street.token}"
            ],
            downloaded_at: DateTime.now.iso8601,
            processing_script: "https://github.com/OpenAddressesUK/sorting_office/tree/195614f8187bb497c59a0caa8ee3fdfce1f1aa2f/lib/models/street.rb"
          }
        ]
      }
    }

    expect(address.provenance).to eq(expected)
    Timecop.return
  end

end
