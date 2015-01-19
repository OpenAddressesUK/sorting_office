class Street

  def self.calculate(address, postcode)
    nearby_streets = Street.where({
      "lat_lng" => {
        "$near" => postcode.lat_lng.to_a,
        "$maxDistance" => 0.00252589038
      }
    })

    matches = []

    nearby_streets.each do |street|
      matches << street if address.gsub(/[^0-9A-Za-z ]/, '').match(/#{street.name.gsub(/[^0-9A-Za-z ]/, '')}/i)
    end

    if matches.count == 1
      return matches.first
    end
  end

end
