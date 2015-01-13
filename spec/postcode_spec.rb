require 'spec_helper'

describe SortingOffice::Postcode do

  it "detects a postcode name" do
    address = "56 Pentire Road, Lichfield, WS14 9SQ"

    postcode = SortingOffice::Postcode.new(address)

    expect(postcode.name).to eq("WS14 9SQ")
  end

end
