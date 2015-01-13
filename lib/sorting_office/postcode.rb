module SortingOffice
  class Postcode

    REGEX = /([A-PR-UWYZ01][A-Z01]?[0-9IO][0-9A-HJKMNPR-YIO]\s?[0-9IO][ABD-HJLNPQ-Z10]{2})/i

    def initialize(address)
      postcode = UKPostcode.new(address.match(REGEX)[0])
      @postcode = ::Postcode.where(name: postcode.norm).first
    end

    (::Postcode.fields.keys - %w(_id created_at updated_at)).each do |field|
      define_method(field) do
        @postcode.send(field)
      end
    end

  end
end
