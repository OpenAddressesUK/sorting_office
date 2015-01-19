class Street

  def self.calculate(address, postcode)
    nearby_streets = Street.where({
      "lat_lng" => {
        "$near" => postcode.lat_lng.to_a,
        "$maxDistance" => 0.00505178075
      }
    })

    matches = []

    nearby_streets.each do |street|
      matches << street if address.gsub(/[^0-9A-Za-z ]/, '').match(/#{street.name.gsub(/[^0-9A-Za-z ]/, '')}/i)
    end

    if matches.count == 1
      return matches.first
    else
      first_match = matches[0]
      second_match = matches[1]

      # If streets cut across boundaries, there may be two records with the same name
      if first_match.name == second_match.name
        return first_match
      end

    end
  end

end
