require 'spec_helper'

describe Town do

  before(:each) do
    FactoryGirl.create(:postcode, name: "EC2A 4JE", area: "EC")
    FactoryGirl.create(:town, name: "LONDON", area: "EC")
    FactoryGirl.create(:town, name: "LONDON", area: "W")
    FactoryGirl.create(:town, name: "LONDON", area: "E")
    FactoryGirl.create(:town, name: "FOO BAR", area: "AB")
    FactoryGirl.create(:town, name: "CLIFTON", area: "AA")
    FactoryGirl.create(:town, name: "FLOOR TOWN", area: "W")
    Town.es.index_all
    Town.es.index.refresh
  end

  it "detects a town name" do
    address = "3rd Floor, 65 Clifton Street, London"
    postcode = Postcode.where(name: "EC2A 4JE").first

    town = Town.calculate(address, postcode)

    expect(town.name).to eq("LONDON")
  end

end
