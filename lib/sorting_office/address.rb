module SortingOffice
  class Address

    attr_accessor :address, :postcode, :town, :locality, :street

    def initialize(address)
      @address = address
    end

    def parse
      get_postcode
      get_town
      get_street
      get_locality
    end

    def get_postcode
      @postcode = Postcode.calculate(@address)
      @address = @address.gsub(@postcode.name, "")
    end

    def get_town
      @town = Town.calculate(@address, @postcode)
      @address = @address.gsub(/#{@town.name}/i, "")
    end

    def get_street
      @street = Street.calculate(@address, @postcode)
      @address = @address.gsub(/#{@street.name}/i, "")
    end

    def get_locality
      @locality = Locality.calculate(@address, @postcode)
      @address = @address.gsub(/#{@locality.name}/i, "") if @locality
    end

  end
end
