require 'spec_helper'

describe Postcode do

  before(:each) do
    FactoryGirl.create(:postcode, name: "EC2A 4JE", easting: 533048, northing: 182126)
  end

  it "detects a postcode name" do
    address = "3rd Floor, 65 Clifton Street, London EC2A 4JE"

    postcode = Postcode.calculate(address)

    expect(postcode[:postcode].name).to eq("EC2A 4JE")
  end

  it "normalises a postcode" do
    address = "3rd Floor, 65 Clifton Street, London ec2a4je"

    postcode = Postcode.calculate(address)

    expect(postcode[:postcode].name).to eq("EC2A 4JE")
  end

  it "inherits the easting and northing from the database item" do
    address = "3rd Floor, 65 Clifton Street, London ec2a4je"

    postcode = Postcode.calculate(address)

    expect(postcode[:postcode].easting).to eq(533048)
    expect(postcode[:postcode].northing).to eq(182126)
  end

  it "replaces the postcode when a postcode has a common error" do
    FactoryGirl.create(:postcode, name: "CV13 0LE", easting: 533048, northing: 182126)
    address = "12 MARKET PLACE, NUNEATON, CV13 OLE"
    result = Postcode.calculate(address)

    expect(result[:address]).to eq("12 MARKET PLACE, NUNEATON, CV13 0LE")
  end

end
