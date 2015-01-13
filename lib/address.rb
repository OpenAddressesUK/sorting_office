class Address

  def initialize(address)
    @address = address
  end

  def postcode
    Postcode.new(address)
  end

end
