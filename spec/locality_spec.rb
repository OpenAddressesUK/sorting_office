require 'spec_helper'

describe Locality do

  before(:each) do
    @postcode = FactoryGirl.create(:postcode, name: "AB1 0AA", lat_lng: [-2.242835, 57.101478])
    @locality = FactoryGirl.create(:locality, name: "TESTVILLE",  lat_lng: [-2.242765, 57.101332])
    FactoryGirl.create(:locality, name: "TESTVILLE",  lat_lng: [-1.242765, 55.101332])
    FactoryGirl.create(:locality, name: "TESTVILLE",  lat_lng: [-1.162765, 53.101332])
    Locality.es.index_all
    Locality.es.index.refresh
  end

  it "detects a locality name" do
    address = "123 High Street, Testville"

    locality = Locality.calculate(address, @postcode.lat_lng)

    expect(locality._id).to eq(@locality._id)
  end

end
