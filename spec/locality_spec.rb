require 'spec_helper'

describe Locality do

  before(:each) do
    @postcode = FactoryGirl.create(:postcode, name: "AB1 0AA", lat_lng: [57.101478, -2.242835])
    @locality = FactoryGirl.create(:locality, name: "TESTVILLE",  lat_lng: [57.101332, -2.242765])
    FactoryGirl.create(:locality, name: "TESTVILLE",  lat_lng: [55.101332, -1.242765])
    FactoryGirl.create(:locality, name: "TESTVILLE",  lat_lng: [53.101332, -1.162765])
    Locality.es.index_all
    Locality.es.index.refresh
  end

  it "detects a locality name" do
    address = "123 High Street, Testville"

    locality = Locality.calculate(address, @postcode)

    expect(locality._id).to eq(@locality._id)
  end

end
