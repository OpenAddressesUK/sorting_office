require 'spec_helper'

describe SortingOffice::Address do

  YAML.load_file('spec/fixtures/test.yml').each do |test_data|

    it "should handle '#{test_data["address"]}'" do
      # Create address parser
      address = SortingOffice::Address.new(test_data["address"])
      # DO IT
      address.get_postcode
      address.get_town
      address.get_street
      address.get_aon
      # Expectations
      expect(address.postcode).to eq(test_data["postcode"])      
      expect(address.town).to eq(test_data["town"])
      expect(address.locality).to eq(test_data["locality"])
      expect(address.street).to eq(test_data["street"])
      expect(address.paon).to eq(test_data["paon"])
      expect(address.saon).to eq(test_data["saon"])
    end
    
  end
  
end
