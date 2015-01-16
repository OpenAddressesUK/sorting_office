class Postcode

  REGEX = /([A-PR-UWYZ01][A-Z01]?[0-9IO][0-9A-HJKMNPR-YIO]\s?[0-9IO][ABD-HJLNPQ-Z10]{2})/i

  def self.calculate(address)
    postcode = UKPostcode.new(address.match(REGEX)[0])
    where(name: postcode.norm).first
  end

end
