class Postcode

  REGEX = /([A-PR-UWYZ01][A-Z01]?[0-9IO][0-9A-HJKMNPR-YIO]?\s?[0-9IO][ABD-HJLNPQ-Z10]{2})/i

  def self.calculate(address)
    matches = address.scan(REGEX)
    if matches.count > 0
      postcode = UKPostcode.new(matches.last[0])
      {
        address: address.gsub(matches.last[0], postcode.norm),
        postcode: where(name: postcode.norm).first
      }
    else
      nil
    end
  end

end
