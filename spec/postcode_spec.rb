require 'spec_helper'

describe SortingOffice::Postcode do

  before(:each) do
    FactoryGirl.create(:postcode, name: "EC2A 4JE", easting: 533048, northing: 182126)
  end

  it "detects a postcode name" do
    address = "3rd Floor, 65 Clifton Street, London EC2A 4JE"

    postcode = SortingOffice::Postcode.new(address)

    expect(postcode.name).to eq("EC2A 4JE")
  end

  it "normalises a postcode" do
    address = "3rd Floor, 65 Clifton Street, London ec2a4je"

    postcode = SortingOffice::Postcode.new(address)

    expect(postcode.name).to eq("EC2A 4JE")
  end

end
