require 'dev_spec_helper'

describe SortingOffice::Address do

  YAML.load_file('spec/fixtures/test.yml').each do |test_data|

    it "should handle '#{test_data["address"]}'" do
      # Create address parser
      address = SortingOffice::Address.new(test_data["address"])
      # DO IT
      address.parse
      # Expectations
      expect(address.postcode.name).to eq(test_data["postcode"])
      expect(address.town.try(:name)).to eq(test_data["town"].upcase)
      expect(address.locality.try(:name)).to eq(test_data["locality"])
      expect(address.street.try(:name)).to eq(test_data["street"].try(:upcase))
      expect(address.paon).to eq(test_data["paon"])
      expect(address.saon).to eq(test_data["saon"])
    end

  end

end
