module SortingOffice
  class Postcode

    REGEX = /([A-PR-UWYZ01][A-Z01]?[0-9IO][0-9A-HJKMNPR-YIO]\s?[0-9IO][ABD-HJLNPQ-Z10]{2})/i

    def initialize(address)
      @address = address
    end

    def name
      postcode = UKPostcode.new(@address.match(REGEX)[0])
      postcode.norm
    end

  end
end
