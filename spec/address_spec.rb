require 'spec_helper'

describe SortingOffice::Address do

  before(:each) do
    FactoryGirl.create(:postcode, name: "EC2A 4JE", area: "EC")
    FactoryGirl.create(:town, name: "LONDON", area: "EC")
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

end
