class Street

  def self.calculate(address, location)
    nearby_streets = Street.where({
      "lat_lng" => {
        "$near" => location.to_a,
        "$maxDistance" => 0.01262945188
      }
    })

    matches = []

    nearby_streets.each do |street|
      matches << street if address.gsub(/[^0-9A-Za-z ]/, '').match(/#{street.name.gsub(/[^0-9A-Za-z ]/, '')}/i)
    end

    if matches.count == 1
      return matches.first
    elsif matches.count == 0
      nil
    else
      first_match = matches[0]
      second_match = matches[1]

      # If streets cut across boundaries, there may be two records with the same name
      if first_match.name == second_match.name
        return first_match
      end

      # Compare the Levenshtein distance between the address and the street name
      distance = matches.map do |m|
        {
          distance: Text::Levenshtein.distance(address.upcase, m.name) ,
          street: m
        }
      end

      # If the distances are all identical, we have a locality that has the same name as a nearby road
      if distance.uniq { |d| d[:distance] }.count == 1
        # Throw away the locality
        a = address.strip.split(/,|\n/)[0...-1].join
        return matches.select { |m| a.match(/#{m.name}/i) }.first
      else
        distance.sort_by { |d| d[:distance] }
        return distance.last[:street]
      end

    end
  end

end
