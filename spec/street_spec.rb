require 'spec_helper'

describe Street do

  before(:each) do
    @postcode = FactoryGirl.create(:postcode, name: "EC2A 4JE", lat_lng: [-0.083648, 51.522387])
    @street = FactoryGirl.create(:street, name: "CLIFTON STREET", lat_lng: [-0.08321407726274722, 51.5224342908254])
    FactoryGirl.create(:street, name: "DYSART STREET", lat_lng: [-0.08403879963203438, 51.52167440645816])
    FactoryGirl.create(:street, name: "PAUL STREET", lat_lng: [-0.08441551241348222, 51.52300246620446])
  end

  it "detects a street" do
    address = "3rd Floor, 65 Clifton Street, London EC2A 4JE"

    street = Street.calculate(address, @postcode.lat_lng)

    expect(street).to eq(@street)
  end

  it "returns one street if there are two records with the same name in close proximity" do
    FactoryGirl.create(:street, name: "CLIFTON STREET", lat_lng: [-0.08321407726274730, 51.5224342908258])
    address = "3rd Floor, 65 Clifton Street, London EC2A 4JE"

    street = Street.calculate(address, @postcode.lat_lng)

    expect(street).to eq(@street)
  end

  it "returns the correct street when the official street name has a special character" do
    s = FactoryGirl.create(:street, name: "ST JOHN'S ROAD", lat_lng: [-0.08321407726274730, 51.5224342908258])
    address = "123 St Johns Road, London EC2A 4JE"

    street = Street.calculate(address, @postcode.lat_lng)

    expect(street).to eq(s)
  end

  it "returns one street if there are two records with similar names in close proximity" do
    st = FactoryGirl.create(:street, name: "UPPER CLIFTON STREET", lat_lng: [-0.08321407726274730, 51.5224342908258])
    address = "3rd Floor, 65 Upper Clifton Street, London EC2A 4JE"

    street = Street.calculate(address, @postcode.lat_lng)

    expect(street).to eq(st)
  end

end
